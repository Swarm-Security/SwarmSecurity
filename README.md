Agent Arena → Webhook → Server
                          ↓
                    Download Repo
                          ↓
                    Load Contracts
                          ↓
                    SolidityAuditor
                          ↓
                    Swarm.analyze_file()
                          ↓
              RoutingAnalyst (selects personas)
                          ↓
        ┌─────────────────┴─────────────────┐
        ↓                                     ↓
  Persona 1 (Thief)              Persona N (OracleExpert)
        ↓                                     ↓
    LLM Analysis                          LLM Analysis
        ↓                                     ↓
  JSON Findings                          JSON Findings
        └─────────────────┬─────────────────┘
                          ↓
                    Aggregate Findings
                          ↓
                    Deduplication
                          ↓
                    Top 20 Selection
                          ↓
                    Format for API
                          ↓
                    POST to Agent Arena
