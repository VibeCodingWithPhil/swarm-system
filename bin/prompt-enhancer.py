#!/usr/bin/env python3

"""
Prompt Enhancer - Applies context engineering to enhance project prompts
"""

import re
import json
from typing import Dict, List, Tuple

class PromptEnhancer:
    """Enhances prompts with proper context engineering"""
    
    def __init__(self):
        self.tech_stack_patterns = {
            'frontend': ['react', 'vue', 'angular', 'next', 'nuxt', 'svelte', 'ui', 'frontend', 'client'],
            'backend': ['node', 'python', 'java', 'go', 'rust', 'api', 'server', 'backend', 'express', 'fastapi', 'django', 'spring'],
            'database': ['postgres', 'mysql', 'mongodb', 'redis', 'sqlite', 'database', 'db', 'sql'],
            'mobile': ['react native', 'flutter', 'swift', 'kotlin', 'ios', 'android', 'mobile'],
            'ai_ml': ['machine learning', 'ml', 'ai', 'tensorflow', 'pytorch', 'model', 'training', 'neural'],
            'cloud': ['aws', 'azure', 'gcp', 'cloud', 'kubernetes', 'docker', 'serverless', 'lambda'],
            'blockchain': ['blockchain', 'smart contract', 'web3', 'ethereum', 'solidity', 'defi', 'nft'],
            'testing': ['test', 'jest', 'pytest', 'cypress', 'selenium', 'unit test', 'integration test'],
            'devops': ['ci/cd', 'jenkins', 'github actions', 'gitlab', 'deployment', 'infrastructure']
        }
        
        self.feature_patterns = {
            'auth': ['authentication', 'auth', 'login', 'signup', 'oauth', 'jwt', 'session'],
            'payment': ['payment', 'billing', 'stripe', 'paypal', 'subscription', 'checkout'],
            'realtime': ['realtime', 'real-time', 'websocket', 'socket.io', 'live', 'streaming'],
            'search': ['search', 'elasticsearch', 'algolia', 'full-text', 'filter', 'query'],
            'file_handling': ['file', 'upload', 'download', 'storage', 's3', 'media', 'image'],
            'email': ['email', 'mail', 'smtp', 'sendgrid', 'notification', 'alert'],
            'analytics': ['analytics', 'metrics', 'tracking', 'dashboard', 'reports', 'statistics'],
            'security': ['security', 'encryption', 'ssl', 'https', 'cors', 'xss', 'csrf'],
            'api': ['api', 'rest', 'graphql', 'endpoint', 'webhook', 'integration'],
            'admin': ['admin', 'management', 'cms', 'panel', 'backoffice', 'moderation']
        }
    
    def enhance_prompt(self, original_prompt: str) -> Dict:
        """Enhance a project prompt with context engineering"""
        
        prompt_lower = original_prompt.lower()
        
        # Detect technologies and features
        detected_tech = self._detect_patterns(prompt_lower, self.tech_stack_patterns)
        detected_features = self._detect_patterns(prompt_lower, self.feature_patterns)
        
        # Generate enhanced prompt
        enhanced = self._build_enhanced_prompt(
            original_prompt,
            detected_tech,
            detected_features
        )
        
        # Generate terminal-specific contexts
        terminal_contexts = self._generate_terminal_contexts(
            detected_tech,
            detected_features
        )
        
        # Generate phase breakdown
        phases = self._generate_enhanced_phases(
            original_prompt,
            detected_tech,
            detected_features
        )
        
        return {
            'original': original_prompt,
            'enhanced': enhanced,
            'detected_tech': detected_tech,
            'detected_features': detected_features,
            'terminal_contexts': terminal_contexts,
            'phases': phases
        }
    
    def _detect_patterns(self, text: str, patterns: Dict) -> List[str]:
        """Detect patterns in text"""
        detected = []
        for category, keywords in patterns.items():
            if any(keyword in text for keyword in keywords):
                detected.append(category)
        return detected
    
    def _build_enhanced_prompt(self, original: str, tech: List[str], features: List[str]) -> str:
        """Build an enhanced prompt with full context"""
        
        enhanced = f"""PROJECT SPECIFICATION:
{original}

TECHNICAL CONTEXT:
- Core Technologies: {', '.join(tech) if tech else 'Full-stack application'}
- Required Features: {', '.join(features) if features else 'Standard application features'}
- Architecture: {'Microservices' if len(tech) > 3 else 'Monolithic'} architecture recommended
- Testing Strategy: Unit tests, integration tests, and Docker-based testing
- Deployment: Containerized with Docker, CI/CD pipeline ready

QUALITY REQUIREMENTS:
- Code Quality: Clean, documented, following best practices
- Performance: Optimized for production use
- Security: Industry-standard security measures
- Scalability: Designed to handle growth
- Maintainability: Modular, testable, well-structured

DELIVERABLES:
1. Complete working application
2. Comprehensive test suite (>80% coverage)
3. Docker configuration for deployment
4. Documentation (README, API docs, user guide)
5. Production-ready configuration

DEVELOPMENT APPROACH:
- Phase 1: Foundation and architecture setup
- Phase 2: Core feature implementation
- Phase 3: Advanced features and integrations
- Phase 4: Polish, optimization, and deployment

SUCCESS CRITERIA:
- All features functional and tested
- Performance benchmarks met
- Security best practices implemented
- Documentation complete
- Deployment automated"""
        
        return enhanced
    
    def _generate_terminal_contexts(self, tech: List[str], features: List[str]) -> Dict:
        """Generate specific context for each terminal"""
        
        contexts = {}
        
        # Terminal 1: Architecture & Backend
        contexts[1] = {
            'role': 'Backend Architecture & Core Systems',
            'focus': 'Server architecture, APIs, business logic',
            'technologies': [t for t in tech if t in ['backend', 'database', 'cloud']],
            'responsibilities': [
                'Design system architecture',
                'Implement core backend services',
                'Set up database schema',
                'Create API structure',
                'Handle authentication/authorization'
            ]
        }
        
        # Terminal 2: Data & Integration
        contexts[2] = {
            'role': 'Data Layer & External Integrations',
            'focus': 'Database, external APIs, third-party services',
            'technologies': [t for t in tech if t in ['database', 'api', 'cloud']],
            'responsibilities': [
                'Database design and optimization',
                'Data migration and seeding',
                'External API integrations',
                'Caching implementation',
                'Data validation and sanitization'
            ]
        }
        
        # Terminal 3: Frontend & UI
        contexts[3] = {
            'role': 'Frontend Development & User Experience',
            'focus': 'UI components, user interactions, responsive design',
            'technologies': [t for t in tech if t in ['frontend', 'mobile']],
            'responsibilities': [
                'UI component development',
                'State management',
                'User interaction flows',
                'Responsive design',
                'Accessibility features'
            ]
        }
        
        # Terminal 4: Features & Business Logic
        contexts[4] = {
            'role': 'Feature Implementation & Business Rules',
            'focus': 'Specific features, business logic, workflows',
            'features': features,
            'responsibilities': [
                'Feature-specific implementations',
                'Business rule enforcement',
                'Workflow automation',
                'Integration coordination',
                'Feature testing'
            ]
        }
        
        # Terminal 5: DevOps & Quality
        contexts[5] = {
            'role': 'DevOps, Testing & Quality Assurance',
            'focus': 'Testing, deployment, monitoring, optimization',
            'technologies': [t for t in tech if t in ['testing', 'devops', 'cloud']],
            'responsibilities': [
                'Test suite development',
                'CI/CD pipeline setup',
                'Docker configuration',
                'Performance optimization',
                'Security hardening'
            ]
        }
        
        return contexts
    
    def _generate_enhanced_phases(self, prompt: str, tech: List[str], features: List[str]) -> Dict:
        """Generate enhanced phase breakdown"""
        
        phases = {
            'phase_1': {
                'name': 'Foundation & Architecture',
                'duration': '25%',
                'goals': [
                    'Set up development environment',
                    'Create project structure',
                    'Configure build tools',
                    'Set up testing framework',
                    'Initialize Docker configuration'
                ],
                'deliverables': [
                    'Complete project scaffold',
                    'Development environment ready',
                    'Basic tests running',
                    'Docker setup complete'
                ]
            },
            'phase_2': {
                'name': 'Core Implementation',
                'duration': '35%',
                'goals': [
                    'Implement main functionality',
                    'Create data models',
                    'Build primary APIs',
                    'Develop core UI components',
                    'Set up authentication'
                ],
                'deliverables': [
                    'Core features working',
                    'Database functional',
                    'Basic UI complete',
                    'Authentication working'
                ]
            },
            'phase_3': {
                'name': 'Advanced Features',
                'duration': '25%',
                'goals': [
                    'Add advanced features',
                    'Implement integrations',
                    'Enhance UI/UX',
                    'Add monitoring',
                    'Optimize performance'
                ],
                'deliverables': [
                    'All features complete',
                    'Integrations working',
                    'Enhanced UI',
                    'Performance optimized'
                ]
            },
            'phase_4': {
                'name': 'Production Ready',
                'duration': '15%',
                'goals': [
                    'Complete testing',
                    'Write documentation',
                    'Set up deployment',
                    'Security hardening',
                    'Final polish'
                ],
                'deliverables': [
                    'Full test coverage',
                    'Complete documentation',
                    'Deployment ready',
                    'Production configurations'
                ]
            }
        }
        
        # Adjust phases based on detected features
        if 'payment' in features:
            phases['phase_2']['goals'].append('Payment integration setup')
        if 'realtime' in features:
            phases['phase_2']['goals'].append('WebSocket infrastructure')
        if 'ai_ml' in tech:
            phases['phase_3']['goals'].append('ML model integration')
        
        return phases

def enhance_project_prompt(original_prompt: str) -> Dict:
    """Main function to enhance a project prompt"""
    enhancer = PromptEnhancer()
    return enhancer.enhance_prompt(original_prompt)

def main():
    """CLI interface for prompt enhancement"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: prompt-enhancer.py \"<project prompt>\"")
        sys.exit(1)
    
    prompt = ' '.join(sys.argv[1:])
    result = enhance_project_prompt(prompt)
    
    print("=" * 80)
    print("ENHANCED PROMPT")
    print("=" * 80)
    print(result['enhanced'])
    print("\n" + "=" * 80)
    print("DETECTED TECHNOLOGIES:", ', '.join(result['detected_tech']))
    print("DETECTED FEATURES:", ', '.join(result['detected_features']))
    print("=" * 80)
    
    # Save to file
    with open('enhanced-prompt.json', 'w') as f:
        json.dump(result, f, indent=2)
    print("\n✓ Full enhancement saved to enhanced-prompt.json")

if __name__ == "__main__":
    main()