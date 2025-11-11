# Kubernetes Course Context & Instructions

## **Important Note: Outdated Course Material**

I am currently following a Kubernetes course that is **5-7 years old** (created around 2018-2020). While the core concepts remain valuable, many specific configurations, tools, and best practices have evolved significantly.

## **Known Outdated Elements**:

- **Image registries**: Uses `k8s.gcr.io` (now deprecated, should be `registry.k8s.io`)
- **Elasticsearch versions**: Uses ES 6.2.5, Kibana 6.2.4 (very old versions)
- **Deprecated addons**: References `fluentd-elasticsearch` removed from Kubernetes core
- **Security practices**: May not reflect current RBAC and security standards
- **Tool versions**: Older versions of kubectl, helm, and other tooling
- **Cloud provider integrations**: AWS/EKS features and best practices have evolved

## **Learning Strategy**:

**📚 Primary Learning**: Follow the course for foundational concepts and architecture understanding

**🤖 Continuous Validation**: Regularly consult GitHub Copilot to:

- Identify what has changed since the course was created
- Learn about current best practices and modern alternatives
- Understand deprecated features and their replacements
- Get updated configuration examples
- Discover new tools and approaches in the ecosystem

## **Custom Instructions for GitHub Copilot Consultations**:

> **Context**: I'm following a 5-7 year old Kubernetes course. When I show you configurations, scripts, or ask about tools:
>
> 1. **Identify outdated elements** and explain what has changed
> 2. **Suggest modern alternatives** where applicable
> 3. **Highlight deprecated features** and their replacements
> 4. **Provide current best practices** for the topic
> 5. **Explain why changes occurred** (security, efficiency, ecosystem evolution)
> 6. **Distinguish between "still works but outdated" vs "completely deprecated"**
> 7. **Recommend whether to follow the course approach or use modern methods**
>
> This helps me learn both historical context and current practices simultaneously.

## **Expected Areas of Evolution**:

- **Container runtimes**: Docker → containerd/CRI-O
- **Networking**: CNI evolution, service mesh adoption
- **Security**: Pod Security Standards, network policies
- **Observability**: Modern monitoring/logging stacks (Prometheus/Grafana, Loki, OpenTelemetry)
- **GitOps**: ArgoCD, Flux for deployment workflows
- **Package management**: Helm 3.x vs older versions
- **Cloud integration**: EKS, GKE, AKS feature evolution

## **Course Content Validation Notes**:

### **EFK Stack (Chapter 15)**

- **Issue**: Course references `fluentd-elasticsearch` addon removed from Kubernetes core
- **Status**: Still functional for learning, but considered legacy
- **Modern Alternative**: Fluent Bit + OpenSearch/Loki + Grafana
- **Licensing**: Elasticsearch 6.2.5 (pre-license change) is safe for educational use

### **Image Registries**

- **Course Uses**: `k8s.gcr.io` (deprecated)
- **Current**: `registry.k8s.io` (official registry)
- **Impact**: Images still accessible but should use modern registry references

### **Kubernetes Versions**

- **Course Version**: Likely covers Kubernetes 1.14-1.16
- **Current Version**: 1.32+ (November 2025)
- **Impact**: Core concepts remain valid, but API versions and features have evolved

## **Learning Validation Process**:

1. **Follow Course**: Learn foundational concepts and architecture
2. **Identify Questions**: Note any configurations or tools that seem outdated
3. **Consult GitHub Copilot**: Attach this context file and ask for validation
4. **Document Findings**: Update notes with modern alternatives
5. **Practice Both**: Understand historical approach and current best practices
6. **Apply Modern**: Use current tools for real-world projects

## **Quick Reference for Consultations**:

**Attach this file to prompts with**:

> "Per my kubernetes-course-context.md, I'm following a 5-7 year old course. Here's what they're showing me: [paste config/question]. Can you analyze this according to my custom instructions?"

This ensures consistent context and gets the most valuable feedback for bridging the gap between course content and current practices.
