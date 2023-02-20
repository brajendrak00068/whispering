
SHELL=/bin/bash
AWS_ACCOUNT_ID = 718762496685
APP_NAME = whisper
REGION = ap-south-1
NAMESPACE = sariska

all: lint_node lint_python

TARGET_DIRS:=./whispering

flake8:
	find $(TARGET_DIRS) | grep '\.py$$' | xargs flake8
black:
	find $(TARGET_DIRS) | grep '\.py$$' | xargs black --diff | python ./scripts/check_null.py
isort:
	find $(TARGET_DIRS) | grep '\.py$$' | xargs isort --diff | python ./scripts/check_null.py
pydocstyle:
	find $(TARGET_DIRS) | grep -v tests | xargs pydocstyle --ignore=D100,D101,D102,D103,D104,D105,D107,D203,D212
pytest:
	pytest
	
yamllint:
	find . \( -name node_modules -o -name .venv \) -prune -o -type f -name '*.yml' -print \
		| xargs yamllint --no-warnings

version_check:
	 git tag | python ./scripts/check_version.py --toml pyproject.toml -i README.md --tags -

lint_python: flake8 black isort pydocstyle version_check pytest


pyright:
	npx pyright

markdownlint:
	find . -type d \( -name node_modules -o -name .venv \) -prune -o -type f -name '*.md' -print \
	| xargs npx markdownlint --config ./.markdownlint.json

lint_node: markdownlint pyright


style:
	find $(TARGET_DIRS) | grep '\.py$$' | xargs black
	find $(TARGET_DIRS) | grep '\.py$$' | xargs isort

.PHONY: help

build-release:
			docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${NAMESPACE}/$(APP_NAME):latest .


push-release:
			docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${NAMESPACE}/$(APP_NAME):latest


deploy-release:
			kubectl kustomize ./k8s | kubectl apply -k ./k8s

deploy: build-release push-release deploy-release