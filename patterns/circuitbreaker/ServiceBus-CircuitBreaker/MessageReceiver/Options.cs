using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MessageReceiver;
internal class Options
{
    public string ServiceBusNamespace { get; set; } = string.Empty;
    public string QueueName { get; set; } = string.Empty;
    public int MaxConcurrentSessions { get; set; }
    public int MaxAutoRenewalDurationSeconds { get; set; }
}
