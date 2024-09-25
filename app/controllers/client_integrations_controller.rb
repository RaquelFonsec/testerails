class ClientIntegrationsController < ApplicationController
    def create
      client_integration = ClientIntegration.new(client_integration_params)
  
      if client_integration.valid?
        if validate_omie_credentials(client_integration)
          render json: { message: 'Credenciais válidas' }, status: :ok
        else
          render json: { error: 'Credenciais inválidas' }, status: :unauthorized
        end
      else
        render json: { error: 'Dados inválidos' }, status: :unprocessable_entity
      end
    end
  
    private
  
    def client_integration_params
      params.require(:client_integration).permit(:company_id, :erp, :erp_key, :erp_secret)
    end
  
    def validate_omie_credentials(client_integration)
      response = HTTParty.post("https://app.omie.com.br/api/v1/financas/contapagar/", body: {
        "call": "ListarContasPagar",
        "app_key": client_integration.erp_key,
        "app_secret": client_integration.erp_secret,
        "param": []
      }.to_json, headers: { 'Content-Type' => 'application/json' })
  
      response.code == 200
    end
  end
  