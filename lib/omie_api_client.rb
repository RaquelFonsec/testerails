# lib/omie_api_client.rb
require 'httparty'

class OmieApiClient
  include HTTParty
  base_uri 'https://app.omie.com.br/api/v1'

  # Validação das credenciais do ERP
  def self.validate_credentials(client_params)
    response = post('/geral/validar', body: {
      company_id: client_params[:company_id],
      erp: client_params[:erp],
      erp_key: client_params[:erp_key],
      erp_secret: client_params[:erp_secret]
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    # Retorna se a resposta indica que as credenciais são válidas
    { valid: response.success? }
  end

  # Criação de contas a pagar
  def self.create_bill(bill_params)
    response = post('/financas/contapagar', body: {
      company_id: bill_params[:company_id],
      description: bill_params[:description],
      amount: bill_params[:amount],
      due_date: bill_params[:due_date]
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.success?
      { success: true, bill_id: response['id'] }
    else
      { success: false, error: response['error'] }
    end
  end

  # Notificação de pagamento
  def self.notify_payment(payment_params)
    response = post('/financas/contapagar/notificar', body: {
      bill_id: payment_params[:bill_id],
      paid_at: payment_params[:paid_at]
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    { success: response.success? }
  end
end
