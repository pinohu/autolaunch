# Using Cursor AI with AutoLaunch Studio

This guide explains how to effectively use Cursor AI as a development tool for AutoLaunch Studio.

## What is Cursor AI?

[Cursor AI](https://cursor.sh) is a coding assistant integrated with VS Code/Visual Studio that helps developers write, understand, and improve code. Unlike deployment platforms with APIs, Cursor AI is a development tool that enhances your coding experience through AI assistance.

## Setting Up Cursor AI for AutoLaunch Studio Development

1. **Install Cursor AI**:
   - Download and install Cursor AI from [https://cursor.sh](https://cursor.sh)
   - Cursor AI is available for macOS, Windows, and Linux

2. **Open AutoLaunch Studio in Cursor AI**:
   - Launch Cursor AI
   - Open the AutoLaunch Studio project folder
   - Cursor AI will automatically load the project and provide AI assistance

3. **Run the Setup Script**:
   ```bash
   # Make the script executable
   chmod +x scripts/cursor-ai/setup_cursor_dev.sh
   
   # Run the setup script
   ./scripts/cursor-ai/setup_cursor_dev.sh
   ```
   
   This script will:
   - Configure VS Code settings for optimal Cursor AI integration
   - Create helpful prompt templates for various development tasks
   - Set up project structure recommendations

4. **Use the Interactive Integration Tool**:
   ```bash
   # Run the integration tool
   node scripts/cursor-ai/cursor_integration.js
   ```
   
   This tool provides:
   - Project structure generation
   - Deployment method configuration
   - Additional Cursor AI prompt generation

## Using Cursor AI for Development

### Basic Commands

- **Open AI Chat**: Press `Cmd+K` (Mac) or `Ctrl+K` (Windows/Linux)
- **Generate Code**: Type a description of what you want to create
- **Edit Code**: Select code and ask Cursor AI to modify it
- **Explain Code**: Select code and ask Cursor AI to explain it

### Using Prompt Templates

We've included prompt templates in the `docs/cursor-prompts` directory for common development tasks:

- General development tasks
- Frontend development (React components, layouts, etc.)
- Backend development (API endpoints, database models, etc.)
- WordPress development (themes, plugins, etc.)
- Browser extension development

To use a template:
1. Open the appropriate template file
2. Copy the prompt you want to use
3. Replace the placeholders in [square brackets]
4. Paste the prompt in the Cursor AI chat

### Development Workflow

1. **Planning Phase**:
   - Use Cursor AI to help plan your feature implementation
   - Ask for architecture recommendations and best practices

2. **Implementation Phase**:
   - Use Cursor AI to generate boilerplate code
   - Ask for help with complex algorithms or patterns
   - Get suggestions for optimizing your code

3. **Testing Phase**:
   - Ask Cursor AI to generate test cases
   - Get help debugging issues

4. **Documentation Phase**:
   - Ask Cursor AI to document your code
   - Generate README files and API documentation

## Best Practices

1. **Be Specific**: The more specific your prompts, the better the results
2. **Provide Context**: Give Cursor AI context about your project and requirements
3. **Iterate**: Refine the generated code to match your needs
4. **Learn**: Study the generated code to improve your own skills
5. **Combine with Human Expertise**: Use Cursor AI as a tool, not a replacement for human judgment

## Deployment

For deployment, AutoLaunch Studio uses standard deployment methods rather than Cursor AI:

- **Docker**: For containerized deployment
- **GitHub Actions**: For CI/CD pipelines
- **Vercel/Netlify**: For frontend deployment
- **Custom Scripts**: For specialized deployment needs

Configure your preferred deployment method using the integration tool:
```bash
node scripts/cursor-ai/cursor_integration.js
```

## Troubleshooting

If you encounter issues with Cursor AI:

1. **Update Cursor AI**: Ensure you're using the latest version
2. **Check Documentation**: Visit [Cursor AI Documentation](https://cursor.sh/docs)
3. **Restart Cursor AI**: Sometimes a simple restart resolves issues
4. **Clear Cache**: Clear the Cursor AI cache if you experience performance issues

## Additional Resources

- [Cursor AI Documentation](https://cursor.sh/docs)
- [VS Code Documentation](https://code.visualstudio.com/docs)
- [AutoLaunch Studio Documentation](docs/README.md)
