namespace singleproject_fsharp_2._0.Controllers

open System
open System.Collections.Generic
open System.Linq
open System.Threading.Tasks
open Microsoft.AspNetCore.Mvc

[<Route("/")>]
type TestsController () =
    inherit Controller()

    [<HttpGet>]
    member this.Get() =
        "Hello World!"


