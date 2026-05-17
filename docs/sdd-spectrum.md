# SDD é Espectro - Escolha o Nível pelo Cenário

**Spec-Driven Development (SDD)** não é binário (especificação ou não). É um **espectro** com 4 níveis diferentes, cada um adequado para um contexto específico.

---

## 📊 Os 4 Níveis de SDD

```
mais leve ←────────────────────────────────────────→ mais rigoroso
   ↓                                                      ↓
Nível 1          Nível 2          Nível 3           Heurística
spec-first    spec-anchored    spec-as-source        DevOps
```

---

## 🟢 Nível 1: Spec-First

### O que é?
Você escreve a **spec ANTES de executar**. A spec guia a implementação, mas não é a fonte de verdade durante o projeto.

### Quando usar
- Mudanças de **alto impacto** (trocar tipo de Service, adicionar HPA)
- **Novos padrões** que precisam ser defendidos depois
- Decisões que precisam ser **auditáveis** e **rastreáveis**

### Frase-gatilho
> "Vou fazer 1 vez, preciso defender essa decisão depois"

### Custo
Especificação **antes** de tudo

### Ganho
- Contrato **auditável**
- Mudança **rastreável**

---

## 🟤 Nível 2: Spec-Anchored ⭐ (Recomendado)

### O que é?
Spec é **código coevaluado**. Toda mudança no código passa por mudança na spec (e vice-versa). A spec é um documento vivo que descreve o estado atual.

### Quando usar
- **Infraestrutura crítica** que muda regularmente (pipeline, CI/CD time inteiro)
- Mudanças que afetam **múltiplos times**
- Quando você quer **zero drift** entre código e documentação

### Frase-gatilho
> "Essa coisa vai mudar mensalmente, e preciso manter a spec viva"

### Custo
Disciplina de **PR** (você atualiza os dois)

### Ganho
- Contrato **sempre fresco**
- Drift **zero** entre código e spec

---

## 🟣 Nível 3: Spec-as-Source

### O que é?
**Código é sempre gerado a partir da spec**. Spec é o artefato único, editável; código gerado é sempre re-gerado a partir dela.

Exemplo: spec → `spec-anchored resolve` → pipeline gerada a partir de manifestos kube

### Quando usar
- **Raro** em DevOps puro
- Pipeline **gerado a partir de manifests Kube**
- Código **nunca diverge** da definição (por construção)

### Frase-gatilho
> "Zero drift garantido"

### Custo
Alto — **exige tooling** de regeneração

### Ganho
- Código **nunca diverge** da spec **por definição**
- Não precisa de review ou sync manual

---

## 🔵 Heurística DevOps

### O que é?
**Sem spec pré-definida**. Você segue **heurísticas** e **princípios** em vez de uma especificação explícita.

Exemplo: "Deploy sempre com padrão X", "Sempre use cert-manager para TLS"

### Quando usar
- **Exploração inicial**, prototipagem
- Times com **alto contexto compartilhado**
- Decisões que **não mudam frequentemente**

### Questões Críticas
1. **Essa mudança vai voltar?** → Spec-first (defenda 1x)
2. **Quanto tempo de doc viva → spec-anchored?** → Regularmente queremos atualizações via spec-anchored
3. **Doc rara mas crítica em revisão?** → Spec-first basta

---

## 🎯 Como Escolher?

### Matriz de Decisão

| Cenário | Impacto | Frequência Mudança | Nível Recomendado |
|---------|---------|-------------------|-------------------|
| Nova feature experimental | Baixo | Rara | Heurística DevOps |
| Mudança em HPA/Service | Alto | Mensal | Spec-anchored |
| Nova pipeline (CI/CD) | Crítico | Semanal+ | Spec-anchored |
| Pattern não testado | Alto | Única | Spec-first |
| Padrão consolidado | Médio | Rara | Heurística DevOps |

---

## 💡 Exemplos Práticos no Kube-News

### 1️⃣ **Spec-First**: Trocar Network Policy
```markdown
# Spec: Network Policy Update

## Objetivo
Restringir tráfego apenas para ingress no namespace kube-news

## Impacto
- Pods não conseguem conectar a serviços fora do namespace
- CI/CD pode quebrar se tira dados de APIs externas

## Defesa
Ganhamos segurança, aceitamos o custo de isolamento

## Implementação
[Depois de aprovado, implementar os manifestos]
```

**Por quê spec-first?** Você quer defender essa decisão depois se quebrar algo.

---

### 2️⃣ **Spec-Anchored**: Pipeline do Kube-News
```yaml
# .github/workflows/deploy.yml (código)
# docs/pipeline-architecture.md (spec)

# Ambos evoluem juntos:
# - Mudança na pipeline → atualiza spec
# - Revisão de spec → valida pipeline
```

**Por quê spec-anchored?** Pipeline muda regularmente (infraestrutura crítica), e você quer zero drift.

---

### 3️⃣ **Spec-as-Source**: Geração de Manifests
```bash
# Spec vive aqui (fonte de verdade)
spec-file.yaml
  ↓
spec-anchored-resolve  # ferramenta que gera
  ↓
k8s/app-deployment.yml  # nunca editar manualmente
```

**Por quê spec-as-source?** Código nunca diverge por construção.

---

### 4️⃣ **Heurística DevOps**: Naming Conventions
```
Convenção: todos os services têm label "app=kube-news"
Sem spec explícita - é conhecimento compartilhado do time
```

**Por quê heurística?** Não muda frequentemente, todos sabem a regra.

---

## ⚡ Workflow Recomendado para Este Projeto

Sua imersão provavelmente usa **Spec-Anchored** (Nível 2):

### Para uma mudança na infraestrutura:

1. **Identifique o tipo de mudança:**
   - "Vou trocar o tipo de deploy?" → Spec-first
   - "Vou atualizar replicas/resources?" → Spec-anchored
   - "Novo padrão nunca testado?" → Spec-first

2. **Se Spec-Anchored:**
   ```bash
   # 1. Atualiza manifesto
   vim k8s-bo/app-deployment.yml
   
   # 2. Atualiza documentação paralela
   vim docs/deployment-architecture.md
   
   # 3. PR com ambos
   git commit -m "Update deployment replicas to 3 and doc"
   git push
   ```

3. **Se Spec-First:**
   ```bash
   # 1. Cria spec
   vim docs/spec-network-policy.md
   
   # 2. Aguarda aprovação
   
   # 3. Implementa com referência à spec
   vim k8s-bo/network-policy.yml
   git commit -m "Implement network policy (ref spec-network-policy.md)"
   ```

---

## 🔑 Pontos-Chave para Explicar para Outros

1. **SDD é espectro, não binário**
   - Não é "com spec" vs "sem spec"
   - É "quanto de formalidade/atualização preciso?"

2. **O nível depende do cenário**
   - Não existe "melhor nível universal"
   - Cada mudança tem seu nível apropriado

3. **Spec-Anchored é o sweet spot**
   - Disciplina de PR (mantém tudo vivo)
   - Sem overhead de tooling (spec-as-source)
   - Sem excesso de formalidade (spec-first)

4. **A pergunta chave é: "Isso vai mudar de novo?"**
   - Sim, frequentemente → spec-anchored
   - Sim, em breve → spec-first
   - Raramente → heurística DevOps

---

## 📚 Para Aprofundar

- Pesquise sobre **"Docs as Code"** (spec-anchored)
- Entenda **Infrastructure as Code** (spec-as-source com IaC tools)
- Conheça **ADR - Architecture Decision Records** (spec-first formalizado)

---

**Criado:** 2026-05-17  
**Para:** Imersão Claude Code DevOps  
**Público:** Equipe, futuros implementadores
