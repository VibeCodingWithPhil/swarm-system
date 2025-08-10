# Contributing to Swarm System

Thank you for your interest in contributing to Swarm System! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use issue templates when available
3. Provide clear descriptions and steps to reproduce
4. Include system information (OS, Python version, etc.)

### Suggesting Features

1. Open a discussion first for major features
2. Explain the use case and benefits
3. Consider implementation complexity
4. Be open to alternative approaches

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write/update tests if applicable
5. Update documentation
6. Commit with clear messages
7. Push to your fork
8. Open a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/swarm-system.git
cd swarm-system

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements-dev.txt

# Run tests
python -m pytest tests/

# Run linting
python -m flake8 bin/
```

## Project Structure

- `bin/` - Core Python scripts and shell scripts
- `kanban/` - Web monitoring interface
- `templates/` - Project templates
- `docs/` - Documentation
- `tests/` - Test suite

## Coding Standards

### Python
- Follow PEP 8
- Use type hints where appropriate
- Write docstrings for all functions/classes
- Keep functions focused and small
- Handle exceptions appropriately

### Shell Scripts
- Use bash shebang: `#!/bin/bash`
- Set error handling: `set -e`
- Quote variables: `"$VAR"`
- Add comments for complex logic
- Test on macOS (primary platform)

### Documentation
- Use Markdown for all docs
- Include code examples
- Keep language clear and concise
- Update README for user-facing changes

## Testing

### Unit Tests
```python
# tests/test_analyzer.py
def test_project_analysis():
    """Test project analysis functionality"""
    result = analyze_project("Build a web app")
    assert result['type'] == 'webapp'
```

### Integration Tests
- Test complete workflows
- Verify file generation
- Check phase transitions
- Validate task distribution

## Commit Messages

Follow conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Maintenance tasks

Example:
```
feat: add support for Ruby projects

- Add Ruby detection in analyzer
- Create Ruby project template
- Update documentation
```

## Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create release branch
4. Run full test suite
5. Create pull request
6. Tag release after merge

## Getting Help

- Open an issue for bugs
- Start a discussion for questions
- Check existing documentation
- Review closed issues/PRs

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to make Swarm System better!