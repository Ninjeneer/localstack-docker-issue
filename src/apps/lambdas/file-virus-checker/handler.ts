import { Context, S3Event } from "aws-lambda";

export const handler = async (event: S3Event, context: Context) => {
	console.log(event);
	console.log(context);
	return {
		statusCode: 200,
		body: JSON.stringify({ message: "Hello, world!" }),
	};
}
