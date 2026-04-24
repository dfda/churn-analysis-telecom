/* PROJETO: Análise de Churn Telecom
   OBJETIVO: Limpeza de dados e criação de flags para facilitar a modelagem no Power BI.
   FERRAMENTA: SQL Server
*/

-- 1. Tratamento de dados nulos e conversão de tipos
WITH Clientes_Tratados AS (
    SELECT 
        customerID,
        gender,
        SeniorCitizen,
        Partner,
        Dependents,
        tenure,
        PhoneService,
        MultipleLines,
        InternetService,
        OnlineSecurity,
        DeviceProtection,
        TechSupport,
        StreamingTV,
        Contract,
        PaperlessBilling,
        PaymentMethod,
        MonthlyCharges,
        -- Tratando 'TotalCharges' que pode vir como texto/vazio
        CAST(NULLIF(TotalCharges, ' ') AS DECIMAL(10,2)) AS TotalCharges,
        Churn
    FROM 
        dbo.Telco_Churn_Raw
),

-- 2. Criação de métricas e segmentações (Business Intelligence)
Base_Analitica AS (
    SELECT 
        *,
        -- Segmentação por tempo de contrato (Fidelidade)
        CASE 
            WHEN tenure <= 12 THEN '0-1 Ano'
            WHEN tenure <= 24 THEN '1-2 Anos'
            WHEN tenure <= 48 THEN '2-4 Anos'
            ELSE 'Mais de 4 Anos' 
        END AS Faixa_Tenure,
        
        -- Flag numérica para o Churn (facilita cálculos de % no BI)
        CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS Churn_Flag,
        
        -- Identificando clientes de alto valor (acima da média de gastos)
        CASE 
            WHEN MonthlyCharges > (SELECT AVG(MonthlyCharges) FROM Clientes_Tratados) THEN 'Alto Valor'
            ELSE 'Valor Padrão' 
        END AS Categoria_Cliente
    FROM 
        Clientes_Tratados
)

SELECT * FROM Base_Analitica;
