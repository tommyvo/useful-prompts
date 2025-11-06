---
description: "Generate documentation for Rails controller"
agent: build
---

# Rails Controller Documentation Generator

## Goal

Generate comprehensive markdown documentation for a Rails controller, including all actions, routes, request/response formats, authentication requirements, and business logic.

**Controller File Path:** {$ARGUMENTS}

## CRITICAL: MANDATORY PROCESS

Follow these steps **IN EXACT ORDER**. DO NOT skip any step:

### Step 1: Identify the Controller (MANDATORY)

**YOU MUST determine which controller file to document:**

- **IF** a controller file path was provided above (not empty) → Use that path
- **ELSE IF** user specifies a controller file → Use that file path
- **ELSE IF** a file is currently open in the editor → Check if it's a controller file
- **ELSE** → STOP and ask the user to provide the controller file path

DO NOT proceed without a valid controller file path.

### Step 2: Read the Controller File (MANDATORY)

**YOU MUST run:** Read the entire controller file from start to finish.

- DO NOT assume you know the controller structure
- DO NOT skip reading the full file
- DO NOT use partial context or memory

### Step 3: Gather Additional Context (REQUIRED)

Read these files if they exist (in order):

1. **Routes file**: `config/routes.rb` - to get route definitions
2. **Related models**: Any models referenced in the controller (e.g., if you see `User.find`, read `app/models/user.rb`)
3. **Concern modules**: Any concerns included in the controller (e.g., `include Authenticatable`)
4. **Parent controller**: Check for authentication/authorization in `ApplicationController` if referenced

### Step 4: Analyze Controller Structure (MANDATORY)

Before generating documentation, identify:

- All public actions (methods)
- All `before_action` / `after_action` / `around_action` filters
- Authentication/authorization methods
- Private/protected helper methods
- Strong parameters (permit/require patterns)

### Step 5: Generate Documentation (MANDATORY)

Create comprehensive documentation following the format specified below.

**Output to Chat ONLY** - DO NOT create files.

Use four backticks (````) for the outer markdown code block.

## Documentation Requirements

For each controller action, you MUST document:

1. **HTTP Method & Route** - The RESTful route and HTTP verb
2. **Purpose** - What the action does
3. **Authentication/Authorization** - Any filters or permission checks
4. **Parameters** - Required and optional parameters (query, path, body)
5. **Request Format** - Expected request body structure with JSON examples
6. **Response Format** - Success and error response structures with status codes
7. **Side Effects** - Database changes, external API calls, email notifications, background jobs
8. **Business Logic** - Key validations, conditionals, and data transformations
9. **Error Handling** - How errors are caught, handled, and returned

## Critical Documentation Guidelines

- **Be thorough**: Include ALL actions, even if some information must be inferred
- **Be specific**: Provide realistic example JSON structures based on actual model attributes
- **Be honest**: If details cannot be determined from code, note as "Not specified in controller" or "Requires additional context"
- **Follow the format**: Use the exact documentation structure provided below

## Documentation Format

The generated documentation should follow this structure:

````markdown
# (Controller Name) Documentation

**Generated:** (Current Date)
**Controller:** `(path/to/controller.rb)`

## Overview

(Brief description of what this controller manages)

## Authentication & Authorization

(Describe authentication requirements, filters, and authorization policies)

Example:

- Requires authentication for all actions via `authenticate_user!`
- Admin access required for destroy action
- Uses CanCanCan for authorization

---

## Actions

### 1. (Action Name) (e.g., index)

**HTTP Method:** `GET`
**Route:** `(route path, e.g., /api/v1/users)`
**Purpose:** (What this action does)

#### Authentication

- (Authentication requirements)

#### Parameters

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | Integer | No | 1 | Page number for pagination |
| `per_page` | Integer | No | 25 | Number of items per page |

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer/String | Yes | Resource identifier |

#### Request Example

```http
GET /api/v1/users?page=1&per_page=25
Authorization: Bearer (token)
```

For POST/PUT/PATCH requests:

```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "role": "admin"
  }
}
```

#### Response

**Success Response (200/201):**

```json
{
  "data": {
    "id": 1,
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin",
      "created_at": "2025-10-29T10:00:00Z"
    }
  },
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 100
  }
}
```

**Error Responses:**

_401 Unauthorized:_

```json
{
  "error": "Authentication required"
}
```

_422 Unprocessable Entity:_

```json
{
  "errors": {
    "email": ["has already been taken"],
    "name": ["can't be blank"]
  }
}
```

#### Business Logic

- (Describe key business logic, validations, or data transformations)
- (List any important conditionals or branching logic)
````
