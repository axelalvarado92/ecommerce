//Configurar Amplify con Cognito
import { Amplify } from "aws-amplify";

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: "us-east-1_bj8qVMNXm",
      userPoolClientId: "5vnk4v5kb8h9j62vdt02bfomhq",
    }
  }
});