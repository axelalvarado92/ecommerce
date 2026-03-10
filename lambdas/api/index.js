const { DynamoDBClient, PutItemCommand, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { v4: uuidv4 } = require("uuid");

const dynamo = new DynamoDBClient({});
const sqs = new SQSClient({});

exports.handler = async (event) => {

    console.log("EVENT:", JSON.stringify(event));

    try {

        const body = typeof event.body === "string"
            ? JSON.parse(event.body)
            : event.body || event;

        const idempotencyKey = event.headers?.["Idempotency-Key"] || event.headers?.["idempotency-key"];

        if (!idempotencyKey) {
            return {
                statusCode: 400,
                body: JSON.stringify({
                    message: "Idempotency-Key header required"
                })
            };
        }

        if (!body.producto) {
            return {
                statusCode: 400,
                body: JSON.stringify({
                    message: "producto is required"
                })
            };
        }

        // Check idempotency
        const existing = await dynamo.send(new GetItemCommand({
            TableName: process.env.TABLE_NAME,
            Key: {
                PK: { S: `IDEMPOTENCY#${idempotencyKey}` },
                SK: { S: "REQUEST" }
            }
        }));

        if (existing.Item) {

            console.log("Idempotency hit");

            return {
                statusCode: 200,
                body: existing.Item.response.S
            };
        }

        const id = uuidv4();

        // Guardar pedido
        await dynamo.send(new PutItemCommand({
            TableName: process.env.TABLE_NAME,
            Item: {
                PK: { S: id },
                SK: { S: "producto" },
                GSI1PK: { S: id },
                GSI1SK: { S: body.producto },
                GSI2PK: { S: id },
                GSI2SK: { S: body.precio?.toString() || "0" },
                GSI3PK: { S: id },
                GSI3SK: { S: body.status || "PENDING" },
                data: { S: JSON.stringify(body) },
                status: { S: "PENDING" }
            }
        }));

        const ttl = Math.floor(Date.now() / 1000) + 86400; // 24h el servicio puede eliminar automáticamente los items cuando ese timestamp expira.

        await dynamo.send(new PutItemCommand({
           TableName: process.env.TABLE_NAME,
            Item: {
            PK: { S: `IDEMPOTENCY#${idempotencyKey}` },
            SK: { S: "REQUEST" },
            response: { S: JSON.stringify({
            message: "Item created",
            id: id
        })},
        ttl: { N: ttl.toString() }
           }
        }));

        // Enviar evento a SQS
        await sqs.send(new SendMessageCommand({
            QueueUrl: process.env.QUEUE_URL,
            MessageBody: JSON.stringify({
                id: id,
                ...body
            })
        }));

        const response = {
            message: "Item created",
            id: id
        };

        // Guardar idempotency key   (importante para que no se genere duplicado)
        await dynamo.send(new PutItemCommand({
            TableName: process.env.TABLE_NAME,
            Item: {
                PK: { S: `IDEMPOTENCY#${idempotencyKey}` },
                SK: { S: "REQUEST" },
                response: { S: JSON.stringify(response) }
            }
        }));

        return {
            statusCode: 200,
            body: JSON.stringify(response)
        };

    } catch (error) {

        console.error("Error:", error);

        return {
            statusCode: 500,
            body: JSON.stringify({
                message: "Internal server error"
            })
        };
    }
};