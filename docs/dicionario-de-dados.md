# Dicionário de Dados — ControlTrip

---

## Tabela: `funcionario`

Cadastro centralizado de colaboradores da organização.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único incremental do funcionário (Chave Primária). |
| `cpf` | CHAR(11) | NÃO | UNIQUE, CHECK (somente 11 dígitos) | CPF único do funcionário, sem formatação. |
| `nome` | VARCHAR(60) | NÃO | — | Nome completo do funcionário. |

---

## Tabela: `setor`

Departamentos ou centros de custo da empresa que realizam os deslocamentos.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único incremental do setor (Chave Primária). |
| `nome` | VARCHAR(60) | NÃO | UNIQUE | Nome descritivo do setor corporativo. |

---

## Tabela: `estado`

Unidades Federativas para mapeamento geográfico e fiscal.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único do estado (Chave Primária). |
| `nome` | VARCHAR(50) | NÃO | UNIQUE | Nome por extenso do estado. |
| `uf` | CHAR(2) | NÃO | UNIQUE, CHECK (2 letras maiúsculas) | Sigla da Unidade Federativa (Ex: SC, SP, RJ). |

---

## Tabela: `cidade`

Municípios para definição de destinos de viagens e cálculo de diárias.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único da cidade (Chave Primária). |
| `nome` | VARCHAR(60) | NÃO | UNIQUE (junto com estadoid) | Nome oficial do município. |
| `estadoid` | INT | NÃO | FK -> `estado.id` | Chave estrangeira ligando a cidade ao estado correspondente. |

---

## Tabela: `categoria`

Classificação contábil da natureza da despesa de viagem.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único da categoria de gasto (Chave Primária). |
| `nome_da_categoria` | VARCHAR(30) | NÃO | UNIQUE | Descrição textual da categoria de despesa. |

---

## Tabela: `moeda`

Tabela de indexação de moedas estrangeiras e taxas de conversão para a moeda do ERP.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único da moeda (Chave Primária). |
| `unidade_monetaria` | VARCHAR(5) | NÃO | UNIQUE | Código internacional ou símbolo da moeda (Ex: BRL, USD, EUR). |
| `cotacao_conversao` | NUMERIC(10,4) | NÃO | CHECK > 0 | Fator multiplicador para conversão de valores para a moeda corrente nacional (BRL). |

---

## Tabela: `os` (Ordem de Serviço)

Ordens de Serviço vinculadas a projetos, clientes ou contratos externos que justificam a viagem.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id_os` | SERIAL | NÃO | PK | ID único da Ordem de Serviço (Chave Primária). |
| `descricao` | VARCHAR(255) | NÃO | — | Detalhamento do escopo técnico ou comercial da Ordem de Serviço. |

---

## Tabela: `viagem`

Entidade mestre que consolida o processo de deslocamento corporativo e adiantamentos.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único da requisição de viagem (Chave Primária). |
| `funcionarioid` | INT | NÃO | FK -> `funcionario.id` | Chave estrangeira identificando o funcionário solicitante/responsável. |
| `cidadeid` | INT | NÃO | FK -> `cidade.id` | Chave estrangeira do município de destino principal. |
| `setorid` | INT | NÃO | FK -> `setor.id` | Chave estrangeira do setor de centro de custos. |
| `osid_os` | INT | NÃO | FK -> `os.id_os` | Chave estrangeira ligando a viagem a uma Ordem de Serviço ativa. |
| `moedaid` | INT | NÃO | FK -> `moeda.id` | Chave estrangeira definindo a moeda padrão do acerto de contas. |
| `status` | VARCHAR(20) | NÃO | DEFAULT 'RASCUNHO', CHECK | Workflow da viagem: `RASCUNHO`, `PENDENTE`, `APROVADO`, `REJEITADO`, `CONCLUIDO`. |
| `justificativa` | VARCHAR(255) | NÃO | — | Argumentação de negócios para validação da gerência. |
| `data_criacao` | DATE | NÃO | DEFAULT CURRENT_DATE | Data de abertura do processo no sistema. |
| `data_fechamento` | DATE | NÃO | CHECK >= data_criacao | Prazo limite do sistema para a prestação de contas. |
| `data_inicio_viagem` | DATE | NÃO | — | Data real de início do deslocamento. |
| `data_termino_fechamento` | DATE | NÃO | CHECK >= data_inicio_viagem | Data real de encerramento contábil e conciliação da viagem. |

---

## Tabela: `viagem_funcionario` (Associativa N:M)

Tabela de ligação para rastrear múltiplos colaboradores compartilhando a mesma viagem.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `viagemid` | INT | NÃO | PK, FK -> `viagem.id` | Identificador da viagem associada. |
| `funcionarioid` | INT | NÃO | PK, FK -> `funcionario.id` | Identificador do funcionário passageiro/acompanhante. |

---

## Tabela: `despesa`

Lançamentos individuais de gastos vinculados a uma prestação de contas de viagem.

| Coluna | Tipo | Nulo | Restrições | Descrição |
|--------|------|------|------------|-----------|
| `id` | SERIAL | NÃO | PK | ID único incremental do lançamento de despesa (Chave Primária). |
| `viagemid` | INT | NÃO | FK -> `viagem.id` (ON DELETE CASCADE) | Chave estrangeira vinculando a despesa à viagem mãe. |
| `categoriaid` | INT | NÃO | FK -> `categoria.id` | Chave estrangeira mapeando a natureza econômica da despesa. |
| `data` | DATE | NÃO | — | Data descrita no comprovante fiscal (nota/recibo). |
| `pagamento` | VARCHAR(25) | NÃO | CHECK (valores fixos) | Método de pagamento: `DINHEIRO`, `CARTAO_CORPORATIVO`, `REEMBOLSO`. |
| `valor` | NUMERIC(15,2) | NÃO | CHECK > 0 | Valor monetário exato do gasto na moeda padrão da viagem. |
| `anexo` | VARCHAR(255) | NÃO | — | Caminho físico (path) ou hash do documento digitalizado. |
| `observacao` | VARCHAR(80) | NÃO | — | Notas complementares para detalhamento de gastos. |
