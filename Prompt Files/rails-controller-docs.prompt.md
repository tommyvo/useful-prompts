---
description: "Generate documentation for Rails controller"
mode: agent
---

# Rails Controller Documentation Generator

## Goal

Generate comprehensive markdown documentation for a Rails controller, including all actions, routes, request/response formats, authentication requirements, and business logic.

## Process

1. **Identify the Controller:**
   - If the user specifies a controller file, use that
   - If not specified, check the current open file or ask the user to provide the controller file path
   - Read the controller file to analyze its structure

2. **Gather Additional Context:**
   - Read related route definitions from `config/routes.rb` if needed
   - Check for related models referenced in the controller
   - Look for any concern modules included in the controller
   - Check for authentication/authorization filters (before_action, etc.)

3. **Generate Documentation:** Create a comprehensive markdown document following the format specified below

4. **Output:** Save the documentation as a new markdown file in the workspace with the naming pattern: `(controller_name)_documentation.md`

## What to Analyze

For each controller action, document:
1. **HTTP Method & Route** - The RESTful route and HTTP verb
2. **Purpose** - What the action does
3. **Authentication/Authorization** - Any filters or permission checks
4. **Parameters** - Required and optional parameters
5. **Request Format** - Expected request body structure (JSON examples)
6. **Response Format** - Success and error response structures
7. **Side Effects** - Database changes, external API calls, email notifications, etc.
8. **Business Logic** - Key validations, conditionals, and data transformations
9. **Error Handling** - How errors are handled and returned

## Instructions

1. Read the specified controller file completely
2. Parse all actions, filters, and helper methods
3. Check routes file for corresponding route definitions
4. Generate complete documentation following the format below
5. **Save the documentation** as a markdown file named `(controller_name)_documentation.md` in the workspace
6. Inform the user where the documentation was saved
7. **Important:** Be thorough - include all actions even if some information is inferred
8. **Important:** Provide realistic example JSON structures based on the actual model attributes
9. If certain details cannot be determined from the code, note them as "Not specified in controller" or "Requires additional context"

## Output

Output the report in Chat as markdown. You can use four backticks (````) for the outer markdown fenced code block, and three backticks for any fenced code blocks within the markdown.

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

*401 Unauthorized:*
```json
{
  "error": "Authentication required"
}
```

*422 Unprocessable Entity:*
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
- (Note any performance considerations)

#### Side Effects

- **Database:** (Describe any create, update, or delete operations)
- **External Services:** (List any API calls, webhooks, or third-party integrations)
- **Background Jobs:** (Note any enqueued jobs)
- **Notifications:** (Mention emails, push notifications, etc.)

#### Error Handling

- (How errors are caught and handled)
- (What error responses are returned)

---

(Repeat the above structure for each action)

---

## Models Referenced

- `(ModelName)` - (Brief description of relationship)
- `(AnotherModel)` - (Brief description of relationship)

## Concerns & Modules

- `(ConcernName)` - (What it provides)

## Key Validations

- (List important validations from the controller or models)

## Security Considerations

- (List any security-related implementations)
- (Note CSRF protection, parameter sanitization, etc.)

## Notes

- (Any additional notes, TODOs, or caveats)
- (Known issues or limitations)
````
