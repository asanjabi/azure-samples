using System;
using System.Collections.Generic;
using System.Text;

namespace Shared
{
    public class MySessionState
    {
        public bool IsCircuitOpen { get; set; } = true;
        public DateTime DateTime { get; set; } = DateTime.UtcNow;
        public DateTime NextRetryUTC { get; set; } = DateTime.UtcNow.AddMinutes(10);
        public string Message { get; set; } = string.Empty;
    }
}
