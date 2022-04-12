
using azure_sql_with_ef6;

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

//Note the line <PackageReference Include="Microsoft.Data.SqlClient" Version="4.1.0" />
//in the project file, this is required to support "Active Directory Default" authentication
//EF6 by default uses version 2.1 which does not support AD Default auth, Version 3.0 or higher is required.
string dbConnectionString = "Server=tcp:sql-4ogmj5slfs42a.database.windows.net,1433; Authentication=Active Directory Default; Database=sqldb-4ogmj5slfs42a;";

Console.WriteLine("starting..");
var options = new DbContextOptionsBuilder().UseSqlServer(dbConnectionString).Options;
var ctx = new WidgetDbContext(options);

ctx.Database.EnsureCreated();

Console.WriteLine("Created");

