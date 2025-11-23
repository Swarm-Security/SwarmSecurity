from typing import List, Dict, Any
from .personas.access_control_expert import AccessControlExpert
from .personas.arithmetic_expert import ArithmeticExpert
from .personas.centralization_expert import CentralizationExpert
from .personas.compiler_expert import CompilerExpert
from .personas.defi_analyst import DeFiAnalyst
from .personas.dos_expert import DoSExpert
from .personas.economic_expert import EconomicExpert
from .personas.error_handling_expert import ErrorHandlingExpert
from .personas.flashloan_expert import FlashLoanExpert
from .personas.frontrunning_expert import FrontrunningExpert
from .personas.gas_optimization_expert import GasOptimizationExpert
from .personas.inheritance_expert import InheritanceExpert
from .personas.interface_expert import InterfaceExpert
from .personas.logician import Logician
from .personas.logic_expert import LogicExpert
from .personas.lowlevel_calls_expert import LowLevelCallsExpert
from .personas.oracle_expert import OracleExpert
from .personas.reentrancy_expert import ReentrancyExpert
from .personas.signature_expert import SignatureExpert
from .personas.storage_proxy_expert import StorageProxyExpert
from .personas.thief import Thief
from .personas.timestamp_expert import TimestampExpert
from .personas.token_expert import TokenExpert
from .personas.validation_expert import ValidationExpert

class Swarm:
    def __init__(self, api_key: str = None, model: str = None):
        # The Council of Agents
        # Add new personas here as you build them
        self.agents = [
            Thief(api_key=api_key, model=model),
            AccessControlExpert(api_key=api_key, model=model),
            ArithmeticExpert(api_key=api_key, model=model),
            CentralizationExpert(api_key=api_key, model=model),
            CompilerExpert(api_key=api_key, model=model),
            DeFiAnalyst(api_key=api_key, model=model),
            DoSExpert(api_key=api_key, model=model),
            EconomicExpert(api_key=api_key, model=model),
            ErrorHandlingExpert(api_key=api_key, model=model),
            FlashLoanExpert(api_key=api_key, model=model),
            FrontrunningExpert(api_key=api_key, model=model),
            GasOptimizationExpert(api_key=api_key, model=model),
            InheritanceExpert(api_key=api_key, model=model),
            InterfaceExpert(api_key=api_key, model=model),
            Logician(api_key=api_key, model=model),
            LogicExpert(api_key=api_key, model=model),
            LowLevelCallsExpert(api_key=api_key, model=model),
            OracleExpert(api_key=api_key, model=model),
            ReentrancyExpert(api_key=api_key, model=model),
            SignatureExpert(api_key=api_key, model=model),
            StorageProxyExpert(api_key=api_key, model=model),
            TimestampExpert(api_key=api_key, model=model),
            TokenExpert(api_key=api_key, model=model),
            ValidationExpert(api_key=api_key, model=model),
        ]

    def analyze_file(self, source_code: str, filename: str) -> List[Dict[str, Any]]:
        """
        Broadcasts the file to all agents in the Swarm.
        """
        findings = []
        
        for agent in self.agents:
            # The agent reasons about the file
            analysis = agent.hunt(source_code, filename)
            
            if analysis.get("found_vulnerability"):
                findings.append({
                    "title": analysis.get('title', 'Unknown Vuln'),
                    "description": analysis.get('kill_chain', 'No details'),
                    "severity": analysis.get('severity', 'High'),
                    "file_path": filename,
                    "line_number": analysis.get('line_number', 0),
                    "confidence": "Verified by Swarm Reasoning",
                    "detected_by": agent.name,
                    "attack_logic": analysis.get('kill_chain', 'See description'),
                    "verification_proof": analysis.get('verification_proof')
                })
            elif analysis.get("optimization_opportunity"):
                gas_savings = analysis.get("gas_savings_estimate", "N/A")
                description = analysis.get(
                    "description",
                    "Gas optimization opportunity identified."
                )
                findings.append({
                    "title": analysis.get("title", "Gas Optimization Opportunity"),
                    "description": f"{description}\n\nEstimated gas savings: {gas_savings}",
                    "severity": analysis.get("severity", "Informational"),
                    "file_path": filename,
                    "line_number": analysis.get("line_number", 0),
                    "confidence": "Optimization recommendation",
                    "detected_by": agent.name,
                    "attack_logic": analysis.get("attack_logic", "Gas optimization reasoning"),
                    "verification_proof": analysis.get("verification_proof")
                })
                
        return findings
