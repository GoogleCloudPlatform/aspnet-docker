using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace MainProject.Controllers
{
    /// <summary>
    /// This controller implements all of the tests for this app.
    /// </summary>
    [Route("/")]
    public class TestsController : Controller
    {
        /// <summary>
        /// Basic serving test, verifies that the app is running by returning a well known
        /// string.
        /// </summary>
        [HttpGet]
        public string ServingTest()
        {
            return "Hello World!";
        }
    }
}
