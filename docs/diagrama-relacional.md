# Diagrama Relacional — ControlTrip

## Modelo Lógico Relacional

```text
+-----------------------------+     1:N     +-----------------------------+
|           estado            |------------>|           cidade            |
+-----------------------------+             +-----------------------------+
| PK  id            SERIAL    |             | PK  id            SERIAL    |
|     nome          VARCHAR   |             |     nome          VARCHAR   |
| UK  uf            CHAR(2)   |             | FK  estadoid      INT       |
+-----------------------------+             +--------------+--------------+
                                                           |
                                                           | 1:N
                                                           v
+-----------------------------+             +-----------------------------+
|         funcionario         |             |           viagem            |
+-----------------------------+             +-----------------------------+
| PK  id            SERIAL    |             | PK  id            SERIAL    |
| UK  cpf           CHAR(11)  |             | FK  funcionarioid INT       |
|     nome          VARCHAR   |             | FK  cidadeid      INT       |
+--------------+--------------+             | FK  setorid       INT       |
               |                            | FK  osid_os       INT       |
               | 1:N                        | FK  moedaid       INT       |
               |                            |     status        VARCHAR   |
               |                            |     justificativa VARCHAR   |
               |                            |     data_criacao  DATE      |
               |      +---------------------+     data_fechamento DATE    |
               |      | 1:N                       data_inicio_viagem DATE |
               v      v                           data_term_fech  DATE    |
+-----------------------------+             +--------------+--------------+
|     viagem_funcionario      |                            |
+-----------------------------+                            | 1:N
| PK,FK viagemid      INT     |                            |
| PK,FK funcionarioid INT     |                            v
+-----------------------------+             +-----------------------------+
|            setor            |             |           despesa           |
+-----------------------------+             +-----------------------------+
| PK  id            SERIAL    |             | PK  id            SERIAL    |
| UK  nome          VARCHAR   |             | FK  viagemid      INT       |
+--------------+--------------+             | FK  categoriaid   INT       |
               |                            |     data          DATE      |
               | 1:N                        |     pagamento     VARCHAR   |
               v                            |     valor         NUMERIC   |
               |                            |     anexo         VARCHAR   |
               |                            |     observacao    VARCHAR   |
               |                            +--------------+--------------+
               |                                           ^
+--------------+              +----------------------------+ 1:N
|              |              |
|              v              | 1:N
|       +--------------+      |             +-----------------------------+
|       |    viagem    |------+             |          categoria          |
|       +--------------+                    +-----------------------------+
|              ^                            | PK  id            SERIAL    |
|              | 1:N                        | UK  nome_da_cat   VARCHAR   |
|              |                            +-----------------------------+
+------------->|
               | 1:N
+--------------+--------------+             +-----------------------------+
|             os              |             |            moeda            |
+-----------------------------+             +-----------------------------+
| PK  id_os         SERIAL    |             | PK  id            SERIAL    |
|     descricao     VARCHAR   |             | UK  unid_monetaria VARCHAR  |
+-----------------------------+             |     cotacao_conversao NUM   |
                                            +-----------------------------+
```

---

## Relacionamentos e Cardinalidades

| Relacionamento | Cardinalidade | Descrição |
|----------------|---------------|-----------|
| `estado` -> `cidade` | 1:N | Um estado possui diversas cidades associadas. |
| `cidade` -> `viagem` | 1:N | Uma cidade pode ser o destino de múltiplas viagens. |
| `setor` -> `viagem` | 1:N | Um setor corporativo pode realizar/custear várias viagens. |
| `os` -> `viagem` | 1:N | Uma Ordem de Serviço pode demandar múltiplas viagens. |
| `moeda` -> `viagem` | 1:N | Uma moeda (como USD, EUR ou BRL) é usada para consolidar e converter os custos de diversas viagens. |
| `funcionario` -> `viagem` | 1:N | Um funcionário pode ser o responsável/solicitante de várias viagens. |
| `viagem` -> `viagem_funcionario` | 1:N | Uma viagem pode registrar vários funcionários associados (N:M). |
| `funcionario` -> `viagem_funcionario` | 1:N | Um funcionário pode participar como acompanhante de várias viagens (N:M). |
| `viagem` -> `despesa` | 1:N | Uma viagem gera múltiplos lançamentos individuais de despesas. |
| `categoria` -> `despesa` | 1:N | Uma categoria de gastos classifica diversas despesas do sistema. |

---

## Normalização e Regras de Negócio

O modelo físico de dados foi totalmente estruturado seguindo as regras da **Terceira Forma Normal (3FN)**:

1. **Primeira Forma Normal (1FN):**
   * Todos os atributos são atômicos e divisíveis (por exemplo, `nome` e `justificativa` são simples e diretos).
   * Não existem grupos repetitivos ou vetores de dados em colunas. As despesas são registradas em sua própria entidade (`despesa`) ligada por chave estrangeira, ao invés de listas ou campos concatenados.

2. **Segunda Forma Normal (2FN):**
   * O modelo já atende à 1FN.
   * Todos os atributos que não são chaves dependem totalmente da totalidade da Chave Primária correspondente.
   * A tabela associativa `viagem_funcionario` possui chave composta (`viagemid`, `funcionarioid`) e não possui atributos adicionais dependentes parciais da chave.

3. **Terceira Forma Normal (3FN):**
   * O modelo atende à 2FN.
   * Não existem dependências transitivas (atributos não chaves dependendo de outros atributos não chaves).
   * O mapeamento de localização foi dividido em `estado` e `cidade` para que dados do estado (como a UF) dependam unicamente da chave de estado, evitando redundâncias e inconsistências na tabela de cidades ou viagens.
   * A conversão de câmbio é baseada na tabela de indexação de moedas externa (`moeda`).
