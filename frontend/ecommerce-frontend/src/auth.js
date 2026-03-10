import { signIn, fetchAuthSession } from "aws-amplify/auth";

export async function login(username, password) {
  const user = await signIn({
    username,
    password
  });

  return user;
}

export async function getToken() {
  const session = await fetchAuthSession();
  return session.tokens.accessToken.toString();
}