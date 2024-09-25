class Api::V1::WebhooksController < ApplicationController
    require 'httparty'
  
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, only: [:validate_credentials, :subscribe]
  
    def validate_credentials
      company_id = params.dig(:client, :company_id)
      erp = params.dig(:client, :erp)
      erp_key = params.dig(:client, :erp_key)
      erp_secret = params.dig(:client, :erp_secret)
  
      success, message = valid_credentials?(erp, erp_key, erp_secret)
  
      final_response = if success
                         { status: 'success', message: 'Credenciais válidas' }
                       else
                         { status: 'error', message: message }
                       end
  
      log_validation_result(company_id, final_response)
      notify_espresso(company_id, final_response)
  
      render json: final_response
    end
  
    def subscribe
      webhook_url = params[:webhook_url]
      events = params[:events]
  
      if webhook_url.blank? || events.blank?
        render json: { status: 'error', message: 'URL do webhook e eventos são obrigatórios.' }, status: :unprocessable_entity
        return
      end
  
      Webhook.create!(url: webhook_url, events: events)
  
      render json: { message: 'Inscrição realizada com sucesso' }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 'error', message: e.message }, status: :unprocessable_entity
    end
  
    def create_account
      reimbursement_data = params[:reimbursement] # Receber dados do reembolso
      # Chame a API do ERP Omie para criar uma conta a pagar
      response = create_account_in_omie(reimbursement_data)
  
      if response.success?
        render json: { status: 'success', message: 'Conta a pagar criada com sucesso' }, status: :ok
        # Notifique o Espresso sobre a criação da conta
        notify_espresso(reimbursement_data[:company_id], { status: 'success', message: 'Conta criada' })
      else
        render json: { status: 'error', message: response.message }, status: :unprocessable_entity
      end
    end
  
    def notify_payment
      payment_data = params[:payment] # Dados sobre o pagamento
      # Notifique o Espresso sobre o pagamento
      notify_espresso(payment_data[:company_id], { status: 'success', message: 'Pagamento realizado' })
  
      render json: { status: 'success', message: 'Notificação enviada' }, status: :ok
    end
  
    private
  
    def valid_credentials?(erp, erp_key, erp_secret)
      response = HTTParty.get("https://app.omie.com.br/api/v1/financas/contapagar/",
                               query: { erp: erp, erp_key: erp_key, erp_secret: erp_secret })
  
      if response.success?
        [true, '']
      else
        [false, response.message || 'Erro ao validar credenciais.']
      end
    rescue StandardError => e
      [false, e.message]
    end
  
    def log_validation_result(company_id, response)
      Rails.logger.info("Resultado da validação para #{company_id}: #{response}")
    end
  
    def notify_espresso(company_id, response)
      webhook_url = "https://example.com/webhook" # Substitua pela URL real do webhook do Espresso
      HTTParty.post(webhook_url, 
                     body: response.to_json, 
                     headers: { 'Content-Type' => 'application/json' })
    end
  
    def create_account_in_omie(reimbursement_data)
      # Implementação para criar a conta a pagar no ERP Omie
      HTTParty.post("https://app.omie.com.br/api/v1/financas/contapagar/",
                     body: reimbursement_data.to_json,
                     headers: { 'Content-Type' => 'application/json' })
    end
  end
  