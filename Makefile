# ============================================================
# RedSpectre / Solidity Audit Agent Template
#
# An AI-powered agent template for auditing Solidity smart
# contracts using OpenAI models.
#
# Features:
#   - Audit Solidity contracts for security vulnerabilities
#   - Security findings classified by threat level:
#       Critical, High, Medium, Low, Informational
#   - Two operation modes:
#       1) Server mode:
#          - Runs a webhook server to receive notifications
#            from AgentArena when a new challenge begins.
#       2) Local mode:
#          - Processes a GitHub repository directly.
#
# ---------------- Server Mode (from README) ------------------
#
# WARNING: The AgentArena platform has not been released yet.
# For now, you can only test the agent locally.
#
# To run the agent in server mode you need to:
#
#   1. Go to the AgentArena website and create a builder account.
#   2. Register a new agent:
#        - Give it a name
#        - Paste in its webhook URL, e.g.:
#              http://localhost:8000/webhook
#        - Generate a Webhook Authorization Token
#        - Copy the AgentArena API key and Webhook Authorization Token
#          into the .env file:
#
#              AGENTARENA_API_KEY=aa-...
#              WEBHOOK_AUTH_TOKEN=your_webhook_auth_token
#              DATA_DIR=./data
#
#   3. Click the Test button in AgentArena to make sure the
#      webhook is working.
#
#   4. Run the agent in server mode:
#
#              audit-agent server
#
#      By default, the agent will run on port 8000.
#      To use a custom port:
#
#              audit-agent server --port 8008
#
# ---------------- Local Mode (from README) -------------------
#
# Run the agent in local mode to audit a GitHub repository
# directly. Example:
#
#   audit-agent local --repo https://github.com/andreitoma8/learn-solidity-hacks.git --output audit.json
#
# The results will be saved in JSON format in the specified
# output file (default: audit.json).
#
# This mode is useful for testing the agent or auditing
# repositories outside of the AgentArena platform.
#
# To see all available options:
#
#   audit-agent --help
#
# License: MIT
# ============================================================

SHELL := /bin/sh
.DEFAULT_GOAL := help

# ANSI colors
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RED    := \033[31m
NC     := \033[0m

# Upstream repo
RED_DIR     := RedSpectre
REPO_URL    := https://github.com/asyaasha7/RedSpectre.git

# Python / venv
PYTHON      ?= python3
VENV_DIR    := $(RED_DIR)/.venv
PYTHON_BIN  := $(VENV_DIR)/bin/python
PIP         := $(VENV_DIR)/bin/pip

# Runtime defaults
PORT   ?= 8000
REPO   ?= https://github.com/andreitoma8/learn-solidity-hacks.git
OUTPUT ?= audit.json

# localtunnel (global lt, as per docs)
LT_CMD := lt --port $(PORT)

# Env vars from README / .env.example
REQUIRED_ENV := AGENTARENA_API_KEY WEBHOOK_AUTH_TOKEN OPENAI_API_KEY

.PHONY: help agentarena-info install clone bootstrap env env-reset \
        check-env run-server run-local node-tools server-tunnel clean

help:
	@printf "\n$(GREEN)RedSpectre / Solidity Audit Agent Template$(NC)\n"
	@printf "-----------------------------------------------------\n"
	@printf "An AI-powered agent for auditing Solidity smart contracts.\n"
	@printf "\n"
	@printf "$(YELLOW)Modes (from upstream README):$(NC)\n"
	@printf "  Server mode:\n"
	@printf "    audit-agent server [--port PORT]\n"
	@printf "    - Webhook server for AgentArena challenges.\n"
	@printf "  Local mode:\n"
	@printf "    audit-agent local --repo REPO_URL --output FILE\n"
	@printf "    - Audit a GitHub repository directly.\n"
	@printf "\n"
	@printf "$(YELLOW)Make targets:$(NC)\n"
	@printf "  make install         - bootstrap + env + start server + tunnel\n"
	@printf "  make env             - create/refresh $(RED_DIR)/.env (.env.example aware)\n"
	@printf "  make env-reset       - force placeholder .env (ignores .env.example)\n"
	@printf "  make check-env       - sanity-check required vars in .env\n"
	@printf "  make run-server      - run 'audit-agent server' on PORT=$(PORT)\n"
	@printf "  make run-local       - run 'audit-agent local' on REPO -> OUTPUT\n"
	@printf "  make server-tunnel   - run server + 'lt --port $(PORT)' tunnel\n"
	@printf "  make agentarena-info - print detailed AgentArena server/local notes\n"
	@printf "  make clean           - remove cloned repo and virtualenv\n"
	@printf "\n"
	@printf "$(YELLOW)Examples:$(NC)\n"
	@printf "  make install\n"
	@printf "  make run-server PORT=8000\n"
	@printf "  make server-tunnel PORT=8000\n"
	@printf "  make run-local REPO=$(REPO) OUTPUT=$(OUTPUT)\n"
	@printf "\n"

agentarena-info:
	@printf "Server Mode (AgentArena):\n\n"
	@printf "  WARNING: The AgentArena platform has not been released yet.\n"
	@printf "  For now, you can only test the agent locally.\n\n"
	@printf "  To run the agent in server mode you need to:\n\n"
	@printf "    1. Go to the AgentArena website and create a builder account.\n"
	@printf "    2. Register a new agent:\n"
	@printf "         - Give it a name\n"
	@printf "         - Webhook URL, for example: http://localhost:8000/webhook\n"
	@printf "         - Generate a Webhook Authorization Token\n"
	@printf "         - Put the keys in RedSpectre/.env:\n"
	@printf "               AGENTARENA_API_KEY=aa-...\n"
	@printf "               WEBHOOK_AUTH_TOKEN=your_webhook_auth_token\n"
	@printf "               DATA_DIR=./data\n\n"
	@printf "    3. Use the Test button in AgentArena to verify the webhook.\n\n"
	@printf "    4. Run the agent in server mode:\n\n"
	@printf "         audit-agent server\n\n"
	@printf "       Default port: 8000\n"
	@printf "       Custom port:\n"
	@printf "         audit-agent server --port 8008\n\n"
	@printf "Local Mode:\n\n"
	@printf "  Example GitHub repository audit:\n\n"
	@printf "    audit-agent local --repo https://github.com/andreitoma8/learn-solidity-hacks.git --output audit.json\n\n"
	@printf "  This mode is useful for testing or auditing repositories\n"
	@printf "  outside of the AgentArena platform.\n\n"
	@printf "  For more options, run:\n\n"
	@printf "    audit-agent --help\n\n"

# ------------------------------------------------------------
# INSTALL (now: bootstrap + env + start server + tunnel)
# ------------------------------------------------------------
install:
	@printf "$(GREEN)Starting full installation and launch...$(NC)\n"
	$(MAKE) bootstrap
	$(MAKE) env
	@printf "$(GREEN)Environment ready. Launching server + tunnel...$(NC)\n"
	$(MAKE) server-tunnel

# ------------------------------------------------------------
# CLONE UPSTREAM REPO
# ------------------------------------------------------------
clone:
	@if [ -d $(RED_DIR) ]; then \
		printf "$(GREEN)Repo already cloned at $(RED_DIR).$(NC)\n"; \
	else \
		printf "$(BLUE)Cloning RedSpectre from $(REPO_URL)...$(NC)\n"; \
		git clone $(REPO_URL) $(RED_DIR); \
	fi

# ------------------------------------------------------------
# PYTHON BOOTSTRAP (venv + install)
# Mirrors upstream:
#   python -m venv venv
#   pip install -e .
# ------------------------------------------------------------
bootstrap: clone
	@printf "$(BLUE)Creating virtualenv at $(VENV_DIR)...$(NC)\n"
	$(PYTHON) -m venv $(VENV_DIR)
	@printf "$(BLUE)Upgrading pip...$(NC)\n"
	$(PYTHON_BIN) -m pip install --upgrade pip
	@printf "$(BLUE)Installing RedSpectre in editable mode...$(NC)\n"
	$(PIP) install -e $(RED_DIR)
	@if [ -f $(RED_DIR)/requirements.txt ]; then \
		printf "$(BLUE)Installing extra requirements from requirements.txt...$(NC)\n"; \
		$(PIP) install -r $(RED_DIR)/requirements.txt; \
	fi
	@printf "$(GREEN)Bootstrap complete.$(NC)\n"

# ------------------------------------------------------------
# ENV CREATION
# Prefer upstream .env.example if present:
#   cp .env.example .env
# Otherwise, synthesize a compatible .env with placeholders.
# ------------------------------------------------------------
env:
	@if [ -f $(RED_DIR)/.env ]; then \
		printf "$(GREEN)$(RED_DIR)/.env already exists (not overwriting).$(NC)\n"; \
	elif [ -f $(RED_DIR)/.env.example ]; then \
		printf "$(BLUE)Creating $(RED_DIR)/.env from .env.example...$(NC)\n"; \
		cp $(RED_DIR)/.env.example $(RED_DIR)/.env; \
		printf "$(GREEN).env created from .env.example. Edit with your configuration.$(NC)\n"; \
	else \
		printf "$(YELLOW).env.example not found. Writing placeholder $(RED_DIR)/.env instead.$(NC)\n"; \
		echo "# OpenAI configuration"                            >  $(RED_DIR)/.env; \
		echo "OPENAI_API_KEY=YOUR_OPENAI_KEY_HERE"              >> $(RED_DIR)/.env; \
		echo "OPENAI_MODEL=gpt-4.1-nano-2025-04-14"             >> $(RED_DIR)/.env; \
		echo ""                                                 >> $(RED_DIR)/.env; \
		echo "# Logging"                                        >> $(RED_DIR)/.env; \
		echo "LOG_LEVEL=INFO"                                   >> $(RED_DIR)/.env; \
		echo "LOG_FILE=agent.log"                               >> $(RED_DIR)/.env; \
		echo ""                                                 >> $(RED_DIR)/.env; \
		echo "# AgentArena / server integration"                >> $(RED_DIR)/.env; \
		echo "AGENTARENA_API_KEY=YOUR_AGENTARENA_KEY_HERE"      >> $(RED_DIR)/.env; \
		echo "WEBHOOK_AUTH_TOKEN=YOUR_WEBHOOK_TOKEN_HERE"       >> $(RED_DIR)/.env; \
		echo "DATA_DIR=./data"                                  >> $(RED_DIR)/.env; \
		echo ""                                                 >> $(RED_DIR)/.env; \
		printf "$(GREEN).env written with placeholder values.$(NC)\n"; \
	fi

# Force overwrite .env with placeholders (ignoring .env.example)
env-reset:
	@printf "$(YELLOW)Overwriting $(RED_DIR)/.env with placeholder values.$(NC)\n"
	@echo "# OpenAI configuration"                            >  $(RED_DIR)/.env
	@echo "OPENAI_API_KEY=YOUR_OPENAI_KEY_HERE"              >> $(RED_DIR)/.env
	@echo "OPENAI_MODEL=gpt-4.1-nano-2025-04-14"             >> $(RED_DIR)/.env
	@echo ""                                                 >> $(RED_DIR)/.env
	@echo "# Logging"                                        >> $(RED_DIR)/.env
	@echo "LOG_LEVEL=INFO"                                   >> $(RED_DIR)/.env
	@echo "LOG_FILE=agent.log"                               >> $(RED_DIR)/.env
	@echo ""                                                 >> $(RED_DIR)/.env
	@echo "# AgentArena / server integration"                >> $(RED_DIR)/.env
	@echo "AGENTARENA_API_KEY=YOUR_AGENTARENA_KEY_HERE"      >> $(RED_DIR)/.env
	@echo "WEBHOOK_AUTH_TOKEN=YOUR_WEBHOOK_TOKEN_HERE"       >> $(RED_DIR)/.env
	@echo "DATA_DIR=./data"                                  >> $(RED_DIR)/.env
	@echo ""                                                 >> $(RED_DIR)/.env
	@printf "$(GREEN).env has been reset to placeholders.$(NC)\n"

# Optional sanity check (does not block server-tunnel)
check-env:
	@if [ ! -f $(RED_DIR)/.env ]; then \
		printf "$(RED)$(RED_DIR)/.env not found. Run: make env$(NC)\n"; \
		exit 1; \
	fi; \
	missing=0; \
	for var in $(REQUIRED_ENV); do \
		val=$$(grep "^$${var}=" $(RED_DIR)/.env | cut -d'=' -f2-); \
		if [ -z "$$val" ] || echo "$$val" | grep -q "YOUR_.*_HERE"; then \
			printf "$(YELLOW)%s is missing or placeholder in .env$(NC)\n" "$${var}"; \
			missing=1; \
		else \
			printf "$(GREEN)%s is set.$(NC)\n" "$${var}"; \
		fi; \
	done; \
	if [ $$missing -eq 1 ]; then \
		printf "$(YELLOW)Some values are still placeholders. Update $(RED_DIR)/.env as needed.$(NC)\n"; \
	else \
		printf "$(GREEN).env looks OK for required variables.$(NC)\n"; \
	fi

# ------------------------------------------------------------
# RUN SERVER (SERVER MODE)
# Mirrors upstream:
#   audit-agent server
#   audit-agent server --port 8008
# ------------------------------------------------------------
run-server: bootstrap
	@printf "$(GREEN)Starting audit-agent server on port $(PORT).$(NC)\n"
	cd $(RED_DIR) && .venv/bin/audit-agent server --port $(PORT)

# ------------------------------------------------------------
# RUN LOCAL AUDIT (LOCAL MODE)
# Mirrors upstream:
#   audit-agent local --repo URL --output FILE
# ------------------------------------------------------------
run-local: bootstrap
	@printf "$(GREEN)Running local audit on $(REPO) -> $(OUTPUT).$(NC)\n"
	cd $(RED_DIR) && .venv/bin/audit-agent local --repo "$(REPO)" --output "$(OUTPUT)"

# ------------------------------------------------------------
# NODE / LOCAL TUNNEL SUPPORT
# Exact flow from localtunnel docs:
#   npm install -g localtunnel
#   lt --port 8000
# ------------------------------------------------------------
node-tools:
	@if ! command -v npm >/dev/null 2>&1; then \
		printf "$(RED)npm not found. Install Node.js + npm first.$(NC)\n"; \
		exit 1; \
	fi
	@if command -v lt >/dev/null 2>&1; then \
		printf "$(GREEN)localtunnel (lt) already installed globally.$(NC)\n"; \
	else \
		printf "$(BLUE)Installing localtunnel globally via npm...$(NC)\n"; \
		npm install -g localtunnel || { \
			printf "$(RED)Failed to install localtunnel via npm.$(NC)\n"; \
			exit 1; \
		}; \
		printf "$(GREEN)localtunnel installed (lt).$(NC)\n"; \
	fi

# ------------------------------------------------------------
# SERVER + TUNNEL COMBO
# Starts:
#   1) audit-agent server --port $(PORT)
#   2) lt --port $(PORT)
# Raw lt output gives you the public loca.lt URL.
# ------------------------------------------------------------
server-tunnel: bootstrap node-tools
	@printf "$(GREEN)Starting audit-agent server on port $(PORT).$(NC)\n"
	cd $(RED_DIR) && .venv/bin/audit-agent server --port $(PORT) & \
	SERVER_PID=$$!; \
	printf "Server PID: %s\n" "$${SERVER_PID}"; \
	sleep 2; \
	printf "$(GREEN)Starting localtunnel with: lt --port $(PORT)$(NC)\n"; \
	$(LT_CMD)

# ------------------------------------------------------------
# CLEAN
# ------------------------------------------------------------
clean:
	@printf "$(YELLOW)Removing cloned repo and virtualenv ($(RED_DIR)).$(NC)\n"
	rm -rf $(RED_DIR)
	@printf "$(GREEN)Clean complete.$(NC)\n"

