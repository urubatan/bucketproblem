# README

This project is a simple REST API for an algorithm to solve "the bucket problem", the API will take 3 parameters, the size of bucket 1 and 2, it will assume an infinite amount of water and will get the desired amount in one of the provided buckets by executing one of 3 operations: fill bucket, empty bucket and transfer from one bucket to another

The api will use memory for caching, this way requests with the same parameters will use the cached values instead of using CPU to calculate the answer again.

## Project setup

There are two options to run this project, you can execute on your own machine using a Ruby environment with the steps in the section "Local Ruby Setup", or you can run as a docker container following the section "Docker Setup"

### Local Ruby Setup

To run this application, you need Ruby 3.3.0 installed. It will probably run with any version above 3.0, but it was tested with the specified version.

After checking out the project with git, using the command:
```bash
git clone https://github.com/urubatan/bucketproblem.git
cd bucketproblem
```

You can download all project dependencies with:
```bash
bundle install
```
The command above needs to be executed only once, and you can run the application from the same directory with the command:
```bash
rails s
```

After that, the application will be running on http://localhost:3000 that is the default rails port

If after configuring the application you want to run the unit tests to make sure the code is working correctly, you can use the command:
```bash
rails test
```

### Docker Setup

To run this application as a docker container, assumming you already have docker configured in your machine or in a server, you simply need to run the following command:

```bash
docker run -d --name bucketproblem -p 3000:3000 urubatan/bucketproblem:latest
```

this will run the application also in localhost and export the port 3000, like in the local setup, the application will be available in http://localhost:3000

## Using the application

To use the application, you need to send post requests to the URL http://localhost:3000/bucket_api

Each post needs to have a JSON payload with 3 fields, the 3 fields need to be positive integers.

The JSON payload will look like this:

```json
{
  "x_capacity": 2,
  "y_capacity": 6,
  "z_amount_wanted": 4
}
```
This request specifies that bucket x had a capacity of 2, bucket y has a capacity of 6 and we want to get 4 from it.

For this request, the response from the API will be something like:

```json
{
  "solution": [
    {
      "step": "fill",
      "bucket": "buckety",
      "buckety_content": 6
    },
    {
      "step": "transfer",
      "from": "buckety",
      "to": "bucketx",
      "transfer_amount": 2,
      "bucketx_content": 2,
      "buckety_content": 4,
      "status": "solved"
    }
  ]
}
```

The returned solution will arrive to the desired value in two steps, it will first fill the bucket y, than it will transfer from bucket y to bucket x, since bucket x only supports 2, it will leave bucket y with 4, solving the request.

To send this payload using `curl`, you can use the following snippet:

```bash
curl "http://localhost:3000/bucket_api"  -X POST -d "{\"x_capacity\": 2,\"y_capacity\": 6,\"z_amount_wanted\": 4}" -H "content-type: application/json" 
```

You could send the same request using Python with the following code:

```python
import requests

url = 'http://localhost:3000/bucket_api'
headers = {'content-type': 'application/json'}
body = """{
      "x_capacity": 2,
      "y_capacity": 6,
      "z_amount_wanted": 4
    }"""

req = requests.post(url, headers=headers, data=body)

print(req.status_code)
print(req.headers)
print(req.text)
```

Or with Ruby, the language the application is written on, using this snippet:

```ruby
require 'uri'
require 'net/http'

url = URI("http://localhost:3000/bucket_api")

http = Net::HTTP.new(url.host, url.port)
request = Net::HTTP::Post.new(url)
request["content-type"] = "application/json"

request.body = { x_capacity: 2, y_capacity: 6, z_amount_wanted: 4 }.to_json

response = http.request(request)

puts response.read_body
```

You can adjust the values in the payload for many different cases, if the parameters are invalid or not possible to calculate the desired amount, the application will return an http response 422, and a JSON with an "error" key with the error description, for example, if we send the payload:

```json
{
  "x_capacity": 2,
  "y_capacity": 6,
  "z_amount_wanted": 5
}
```

The returned response would be an HTTP code 422 with this JSON explaining the error:

```json
{
  "error": "Impossible to calculate with the provided params"
}
```

There are some complex cases that this algorithm will not be able to calculate, but are possible values, for example if you send the payload:

```json
{
  "x_capacity": 3,
  "y_capacity": 5,
  "z_amount_wanted": 4
}
```
The result is possible, but the algorithm implemented will not be able to resolve it, so it will return an HTTP response 422 with an error description.