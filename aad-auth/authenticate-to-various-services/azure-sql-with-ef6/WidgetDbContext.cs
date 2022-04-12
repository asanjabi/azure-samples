using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.EntityFrameworkCore;

namespace azure_sql_with_ef6;

internal class WidgetDbContext: DbContext
{
    public WidgetDbContext(DbContextOptions options): base(options)
    {

    }

    public DbSet<Widget> Widgets => Set<Widget>();

}
