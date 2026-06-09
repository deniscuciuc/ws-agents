# Workflow: MCP Tool Triage

## Trigger
When an MCP tool fails, returns unexpected results, or needs diagnosis.

## Steps
1. Check the tool name and expected operation
2. Verify the MCP server is running
3. Check environment variables for auth credentials
4. Test with a direct JSON-RPC call
5. Check logs for error messages
6. Verify tool arguments match the schema
7. Check rate limits and timeout settings

## Common Issues
| Symptom | Likely Cause |
|---|---|
| Tool not found | Server not started or tool list changed |
| Auth error | Missing or expired token/env variable |
| Timeout | Network issue or server overload |
| Unexpected response | Schema mismatch or API version change |
| Server not running | Process died or config error |

## Resolution Path
1. Restart the MCP server process
2. Verify auth tokens are current
3. Check server logs for startup errors
4. Validate configuration file syntax
5. Test with `echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | <server-command>`
