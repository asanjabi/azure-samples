namespace MessageSender;
internal class Options
{
    public string ServiceBusNamespace { get; set; } = string.Empty;
    public string QueueName { get; set; } = string.Empty;
    public int BatchSize { get; set; }  //How many messages in a batch
    public int Sessions { get; set; }   //How many sessions
    public int Pause { get; set; }      //How long to pause between batches.
}
