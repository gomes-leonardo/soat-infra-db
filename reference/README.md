# Referência: RDS na AWS (não aplicado)

Módulo `aws-rds/` herdado da Fase 2: PostgreSQL 16 no RDS, com credencial no Secrets Manager e
`multi_az` por perfil. **Não é aplicado.** RDS e Secrets Manager cobram desde o primeiro minuto,
e esta entrega tem restrição de custo zero (RFC de nuvem e custo, no repositório da aplicação).

O pipeline continua validando o módulo (`terraform validate`), para que ele não apodreça. O caminho
de volta para a AWS paga é trocar `module "neon"` por este módulo no `env/` e escrever o mesmo
Secret `soat-db`. A aplicação não muda.
