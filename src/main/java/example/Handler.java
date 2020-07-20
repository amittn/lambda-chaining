package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.Map;

// Handler value: example.Handler
public class Handler implements RequestHandler<Map<String,String>, String>{
  Gson gson = new GsonBuilder().setPrettyPrinting().create();
  @Override
  public String handleRequest(Map<String,String> event, Context context)
  {
    System.out.println("++++++++++++++++++++2+++++++++++++++++++++");
    LambdaLogger logger = context.getLogger();
    String val2 = event.get("key12");
    System.out.println("val2 "+ val2);
    val2 = val2 + " please note this changes are made in the 2nd Lambda and send back to the caller Lambda";
    System.out.println("val2 =="+ val2);
    //String response = new String("200 OK");
    // log execution details
    logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
    logger.log("CONTEXT: " + gson.toJson(context));
    // process event
    logger.log("EVENT: " + gson.toJson(event));
    logger.log("EVENT TYPE: " + event.getClass().toString());
    return val2;
  }
}