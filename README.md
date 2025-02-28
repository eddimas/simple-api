# Scalable Serverless Event Processing System

## Overview

This project implements a scalable, event-driven system that processes, analyzes, and stores data from simulated devices using AWS serverless technologies.  
The system is designed with best practices for Infrastructure as Code (IaC), CI/CD automation, security, and scalability.

## Features

- Event-Driven Architecture: Uses AWS services like API Gateway, Lambda, , and S3.
- Serverless Processing Pipeline: Multi-stage processing with validation, feature extraction, and parallel execution.
- Secure and Optimized: Implements least-privilege IAM roles, API authentication, encryption, and custom retry mechanisms.
- Fully Automated Deployment: Uses Terraform for infrastructure provisioning and GitHub Actions for CI/CD.

## API Endpoints

### 1. Ingest Device Data

**Endpoint:** `POST /data`  
**Description:** Accepts event data from simulated devices and validates the input  
**Request Headers:** `x-api-key: ${SECRET-KEY}$`
**Request Body (JSON Example)**

```json
{
  "device_id": "12345",
  "timestamp": "2025-02-28T12:00:00Z",
  "value": 22.5
}
```

**Response:**

`200 OK`: Data processed and stored successfully  
`400 Bad Request`: Invalid request format

---

### 2. Retrieve Processed Data

**Endpoint:** `GET /`  
**Description:** Fetches processed data for a specific device from .  
**Request Headers:** `x-api-key: ${SECRET-KEY}$`
**Response Example:**

```
Method response body after transformations: {"mean": 66, "median": 40, "standard_deviation": 49.426}
```

- `200 OK`: Returns processed data.
- `404 Not Found`: No data found for the specified device.

---

## Deployment

### Prerequisites

- **Github CLI**
- **AWS CLI configured**
- **Terraform installed**
- **GitHub Actions enabled**

### Steps

#### Forking this repository

To create a fork of a repository, use the gh repo fork subcommand.

```sh
gh repo fork REPOSITORY
```

### Cloning your forked repository

Right now, you have a fork of the Spoon-Knife repository, but you do not have the files in that repository locally on your computer.

To create a clone of your fork, use the --clone flag.

```sh
gh repo fork REPOSITORY --clone=true
```

### Configuring Git to sync your fork with the upstream repository

When you fork a project in order to propose changes to the upstream repository, you can configure Git to pull changes from the upstream repository into the local clone of your fork.

To configure a remote repository for the forked repository, use the --remote flag.

```sh
gh repo fork REPOSITORY --remote=true
```

To specify the remote repository's name, use the --remote-name flag.

```sh
gh repo fork REPOSITORY --remote-name "main-remote-repo"
```

### Make changes to the code

**Push code changes to trigger the CI/CD pipeline**:

```sh
    git add .
    git commit -m "Deploy update"
    git push origin main
```

## Security Measures

- IAM roles follow the least-privilege principle.
- API Gateway authentication is enforced.
- Data is encrypted in transit (TLS) and at rest (S3).

## Next Steps

- Add unit tests for Lambda functions.
- Implement health checks and error handling.
- Add monitoring dashboards with CloudWatch.
- Optimize costs with Lambda provisioned concurrency.

## Appendix

### Solution diagram

![simple-api architecture](images/simple-api.png)  
**Figure 1:** Architecture diagram of the simple API.
