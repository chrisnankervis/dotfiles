**Commits**   
When committing code:
- Keep commits scoped to one distinct change
- Follow the conventional commits specification using the following format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```
- Explain why the change was made in the body
- Add yourself as a co-author

**Pull Requests**   
When creating Pull Requests:   
- Include Summary, Testing/Validation and Risks sections:   
  - Summary:
    - A concise description of the proposed changes and the reason they were made
    - Provide any additional context that may make it easier to review
    - Prefer sentences over bullet points
  - Testing/Validation:
    - An explanation of any manual testing or validation that was done to build confidence in the implementation
    - Include any suggestions around what to test once this code is deployed, if relevant
  - Risks:
    - A summary of the changes within the context of the larger codebase and the most significant risks
    - Prefer concise bullet points
