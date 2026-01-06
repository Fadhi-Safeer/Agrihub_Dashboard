# backend/mcp_tools/server.py
from mcp_framework import MCPServer, tool  # pseudo import

from .vision_tools import get_overall_status, get_disease_overview
from .iot_tools import get_environment_trends

server = MCPServer("agrihub-insights")

@tool(name="get_overall_status")
def t_get_overall_status(days: int = 14) -> dict:
    """
    Return overall farm health summary for the last N days.
    """
    return get_overall_status(days)

@tool(name="get_disease_overview")
def t_get_disease_overview(days: int = 14) -> dict:
    """
    Return disease counts by type for the last N days.
    """
    return get_disease_overview(days)

@tool(name="get_environment_trends")
def t_get_environment_trends(days: int = 14) -> dict:
    """
    Return temperature, humidity and soil moisture summaries for last N days.
    """
    return get_environment_trends(days)

if __name__ == "__main__":
    server.run()
