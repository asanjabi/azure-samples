## This project uses a pre-release version of a few SDK libraries.
These are located in the located in the *SDK* folder built from source at https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/servicebus, and should be removed once updated nuget packages are available:
Before updating packages remove the following: 
- `Azure.Core.Amqp`
- `Microsfot.Azure.Amqp`
- `Microsoft.Azure.WebJobs`


Then add the following when available
- `Azure.Messaging.Servicebus` replace with a version higher than 7.9.0  
- `Microsoft.Azure.WebJobs.Extensions.ServiceBus` replace with version higher than 5.5.1  

