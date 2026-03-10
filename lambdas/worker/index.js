const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  console.log("EVENT:", JSON.stringify(event));

  for (const record of event.Records) {
    try {

      const body = JSON.parse(record.body);

      if (!body.id) {
        console.warn("Missing id in message:", body);
        continue;
      }

      const item = {
        PK: body.id,
        SK: "producto",
        GSI1PK: body.id,
        GSI1SK: body.producto || "default",
        GSI2PK: body.id,
        GSI2SK: body.precio?.toString() || "0",
        GSI3PK: body.id,
        GSI3SK: body.status || "PENDING",
        data: JSON.stringify(body),
        name: body.name || "unknown",
        createdAt: body.timestamp || new Date().toISOString(),
        status: body.status || "PENDING"
      };

      await dynamo.send(
        new PutCommand({
          TableName: process.env.TABLE_NAME,
          Item: item
        })
      );

      console.log("Item saved:", item);

    } catch (error) {

      console.error("Error processing record:", error);

      // Esto hace que SQS reintente el mensaje
      throw error;
    }
  }
};