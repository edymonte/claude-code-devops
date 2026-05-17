# 📚 Documentação Central - Kube-News DevOps

Todos os documentos de referência, conceitos e arquitetura estão centralizados aqui.

---

## 📖 Índice de Documentos

### 🏗️ Arquitetura & Conceitos

- **[SDD é Espectro](./sdd-spectrum.md)** — Spec-Driven Development nos 4 níveis
  - Entenda quando usar spec-first, spec-anchored, spec-as-source ou heurística DevOps
  - Exemplos práticos no projeto Kube-News
  - Como escolher o nível apropriado

### 🚀 Guias de Operação

- **[CLAUDE.md](../CLAUDE.md)** — Guia para Claude Code trabalhar no repositório
  - Arquitetura técnica
  - Comandos comuns
  - Endpoints da aplicação
  - Known issues e lições aprendidas

- **[MONITORING_GUIDE.md](../MONITORING_GUIDE.md)** — Como usar Prometheus + Grafana
  - Setup local
  - Exemplo de queries
  - Criar dashboards
  - Troubleshooting

### 📋 Análises & Incidentes

- **[POSTMORTEM.md](../POSTMORTEM.md)** — Análise do incidente do primeiro dia
  - Causa raiz: Block Storage `lost+found`
  - Timeline completa
  - Resolução aplicada
  - **Essencial para evitar repetir o mesmo erro**

### 🔧 Configuração & Setup

- **[README.md](../README.md)** — Documentação principal do projeto
  - Sobre o Kube-News
  - Tecnologias
  - Estrutura do projeto
  - Instalação local

---

## 🎯 Como Usar Esta Documentação

### Para Desenvolvedores Novos
1. Comece em **[CLAUDE.md](../CLAUDE.md)** para entender o contexto
2. Leia **[README.md](../README.md)** para a visão geral
3. Estude **[POSTMORTEM.md](../POSTMORTEM.md)** para evitar armadilhas

### Para Entender Decisões
1. Consulte **[SDD é Espectro](./sdd-spectrum.md)** para aprender o framework
2. Procure comentários no CLAUDE.md sobre "Nível X" ou "Spec-anchored"
3. Verifique POSTMORTEM.md para decisões passadas

### Para Trabalhar com Monitoramento
→ **[MONITORING_GUIDE.md](../MONITORING_GUIDE.md)**

### Para Implementar Mudanças
→ **[CLAUDE.md](../CLAUDE.md)** (Development Tasks)

---

## 📝 Convenções de Documentação

Ao adicionar novos documentos, siga:

1. **Localização**: Todos em `/docs/`
2. **Naming**: kebab-case (ex: `database-schema.md`)
3. **Estrutura**:
   - Título nível 1 (#)
   - Descrição breve
   - Índice se > 500 palavras
   - Exemplos práticos
   - Links para referências relacionadas

4. **Links**: Sempre use caminhos relativos
   ```markdown
   [CLAUDE.md](../CLAUDE.md)
   [SDD Guide](./sdd-spectrum.md)
   ```

---

## 🔄 Como Manter Documentação Viva

**Regra: Spec-Anchored**

Quando mudar código, **sempre** atualize a documentação correspondente:

```bash
# Exemplo: Mudança em K8s manifests
git commit -m "Update deployment replicas to 3

- Modified: k8s-bo/app-deployment.yml
- Updated: docs/deployment-architecture.md (ou CLAUDE.md)
- Reason: High load requires more replicas"
```

Isso garante que **zero drift** entre código e documentação.

---

## 📚 Próximos Documentos para Criar

- [ ] Database Schema & Migrations
- [ ] API Specification
- [ ] Testing Strategy
- [ ] Performance Tuning Guide
- [ ] Security Checklist
- [ ] Disaster Recovery Playbook

---

**Última atualização**: 2026-05-17  
**Mantido por**: Equipe Imersão Claude Code DevOps
