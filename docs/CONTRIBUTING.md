# Contributing to PentaOS

Thank you for your interest in contributing to PentaOS! This document provides guidelines and instructions for contributing to the project.

## Ways to Contribute

- 🐛 **Report Bugs** - Found an issue? Let us know
- 💡 **Suggest Features** - Have an idea? Share it
- 📝 **Improve Documentation** - Help us improve our docs
- 🔧 **Submit Code** - Contribute features or fixes
- 🧪 **Test** - Help us test on various Raspberry Pi models
- 📢 **Spread the Word** - Tell others about PentaOS

## Getting Started

### Prerequisites

```bash
# Required tools
sudo apt-get install -y git build-essential wget xz-utils

# Optional but recommended
sudo apt-get install -y shellcheck
```

### Setting Up Your Development Environment

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/yourusername/pentaos.git
cd pentaos

# Add upstream remote
git remote add upstream https://github.com/original/pentaos.git

# Create a branch for your feature
git checkout -b feature/your-feature-name
```

## Development Workflow

### Creating a Feature Branch

```bash
# Update main branch
git fetch upstream
git checkout main
git rebase upstream/main

# Create feature branch
git checkout -b feature/descriptive-name
```

### Making Changes

1. Make your changes in your feature branch
2. Test thoroughly
3. Follow the coding guidelines below
4. Commit with clear, descriptive messages

### Commit Messages

Write clear commit messages:

```
Add feature: Brief description

More detailed explanation of what changed and why.
- Explain the problem
- Describe the solution
- Reference any issues (#123)

Fixes #123
```

### Testing Your Changes

```bash
# Lint shell scripts
shellcheck build/*.sh

# Test build process
./build/build-pentaos.sh

# Verify documentation
grep -r TODO docs/
```

## Coding Guidelines

### Shell Script Standards

```bash
#!/bin/bash
# Clear shebang

set -e  # Exit on error

# Use meaningful variable names
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Quote variables
echo "$variable"

# Use functions for clarity
function_name() {
    # Function body
    local local_var="value"
}

# Error handling
if ! command_name; then
    echo "Error occurred"
    exit 1
fi
```

### Documentation Standards

- Use clear, concise language
- Include examples where helpful
- Link to related documentation
- Keep line length under 80 characters
- Use proper markdown formatting

### Commit Best Practices

- One feature per commit
- Atomic commits that don't break tests
- Reference issues in commit messages
- Keep commits small and focused

## Submitting Changes

### Pull Request Process

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request:**
   - Go to GitHub and open a PR
   - Follow the PR template
   - Link related issues
   - Provide clear description

3. **PR Description Template:**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Performance improvement

   ## Testing
   How were these changes tested?

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] No new warnings generated
   - [ ] Tested on Raspberry Pi hardware
   ```

4. **Address Feedback:**
   - Respond to review comments
   - Make requested changes
   - Re-request review when ready

5. **Merge:**
   - Requires approval from maintainers
   - CI/CD tests must pass
   - Commits will be squashed

## Reporting Bugs

### Creating a Bug Report

Include:
- **Title:** Clear, concise description
- **Environment:** Raspberry Pi model, OS version, etc.
- **Steps to reproduce:** Detailed steps
- **Expected behavior:** What should happen
- **Actual behavior:** What actually happened
- **Logs/output:** Relevant error messages
- **Screenshots:** If applicable

### Bug Report Template

```markdown
## Description
A clear description of the bug.

## Environment
- Raspberry Pi Model: 4B / 5
- OS Version: PentaOS 1.0.0
- Kernel: Linux 6.x.x

## Steps to Reproduce
1. First step
2. Second step
3. Third step

## Expected Behavior
What should happen

## Actual Behavior
What actually happened

## Error Logs
```
[paste logs here]
```

## Suggesting Features

### Feature Request Template

```markdown
## Description
Description of the feature

## Problem Statement
Why is this feature needed?

## Proposed Solution
How should it work?

## Alternative Solutions
Are there other approaches?

## Additional Context
Any other relevant information
```

## Documentation Contributions

### Improving Docs

1. Fork and clone the repository
2. Edit markdown files in `docs/`
3. Test markdown formatting locally:
   ```bash
   # Preview markdown
   pandoc docs/CONFIGURATION.md -t html
   ```
4. Submit pull request with improvements

### Documentation Style

- Use markdown formatting
- Include code examples with syntax highlighting
- Add table of contents for long documents
- Include headers and sections for organization
- Link to related documents

## Testing Contributions

### Running Tests

```bash
# Build the OS
./build/build-pentaos.sh

# Flash to test hardware
sudo ./build/flash-sd-card.sh /dev/sdX

# Document your test results
```

### Test Coverage Needed

- [ ] Build on Ubuntu 22.04 LTS
- [ ] Build on Debian Bookworm
- [ ] Flash to Raspberry Pi 3B+
- [ ] Flash to Raspberry Pi 4B
- [ ] Flash to Raspberry Pi 5
- [ ] First boot on each model
- [ ] SSH connectivity
- [ ] Basic performance check

## Code Review Process

### What We Look For

✅ **Good submissions:**
- Clear problem statement
- Well-tested changes
- Good documentation
- Follows style guidelines
- Addresses review feedback

❌ **Issues we'll request changes for:**
- Incomplete tests
- Missing documentation
- Style inconsistencies
- Breaking changes without discussion
- Large refactors without approval

## Community

### Code of Conduct

We're committed to providing a welcoming and inspiring community for all.

- Be respectful and inclusive
- Welcome diverse perspectives
- Assume good intent
- Focus on what matters

### Getting Help

- **Documentation:** Check [README.md](../README.md)
- **Issues:** Search existing issues first
- **Discussions:** Join GitHub Discussions
- **Contact:** Maintainers are happy to help

## Project Roadmap

### Planned Features

- [ ] Custom boot splash screen
- [ ] Optimized desktop environment
- [ ] Pre-configured development tools
- [ ] Performance benchmarking tools
- [ ] System update notifications
- [ ] Hardware health monitoring

### Known Issues

See [Issues](https://github.com/yourusername/pentaos/issues) for current issues.

## Recognition

Contributors will be recognized in:
- Release notes
- Contributors list
- GitHub contributors page

## Questions?

- Open an issue for discussions
- Check existing documentation
- Ask in GitHub Discussions

---

Thank you for contributing to PentaOS! 🙏

Last Updated: 2026-09-13
