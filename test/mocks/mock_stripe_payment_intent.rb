class MockStripePaymentIntent
   
   INVALID_PAYMENT = "invalid_payment"
   REQUIRES_ACTION = "requires_action"
   
   cattr_accessor :intents
   self.intents = []
   
   attr_reader :options, :id
   
   def MockStripePaymentIntent.create(options = {})
      if options[:payment_method] === INVALID_PAYMENT
         raise Stripe::CardError.new("Card Declined", options[:payment_method], json_body: CARD_DECLINED_JSON_BODY)
      end
       pi = MockStripePaymentIntent.new(options)
       self.intents << pi
       return pi
   end
   
   def MockStripePaymentIntent.retrieve(id) 
      self.intents.find{|pi| pi.id == id}
   end
   
   def status
      case options[:payment_method] 
         when INVALID_PAYMENT
            return "failed"
         when REQUIRES_ACTION
            return "requires_action"
         else
            return "succeeded"
      end
   end
   
   def next_action
      return Class.new do
         def type
            "use_stripe_sdk"
         end
      end 
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = "pi" + rand(100000...999999).to_s
   end
   
   def to_s
      "[MockStripePaymentIntent:id=#{@id}]"
   end
   
   
   CARD_DECLINED_JSON_BODY = <<-EOS
   {
  "error": {
    "charge": "ch_1FDyGyF1DucEZKNDWV67iZeh",
    "code": "card_declined",
    "decline_code": "generic_decline",
    "doc_url": "https://stripe.com/docs/error-codes/card-declined",
    "message": "Your card was declined.",
    "payment_intent": {
      "id": "pi_1FDyGyF1DucEZKNDar4JWkTV",
      "object": "payment_intent",
      "amount": 625,
      "amount_capturable": 0,
      "amount_received": 0,
      "application": null,
      "application_fee_amount": null,
      "canceled_at": null,
      "cancellation_reason": null,
      "capture_method": "automatic",
      "charges": {
        "object": "list",
        "data": [
          {
            "id": "ch_1FDyGyF1DucEZKNDWV67iZeh",
            "object": "charge",
            "amount": 625,
            "amount_refunded": 0,
            "application": null,
            "application_fee": null,
            "application_fee_amount": null,
            "balance_transaction": null,
            "billing_details": {
              "address": {
                "city": null,
                "country": "US",
                "line1": null,
                "line2": null,
                "postal_code": null,
                "state": null
              },
              "email": null,
              "name": null,
              "phone": null
            },
            "captured": false,
            "created": 1567364376,
            "currency": "usd",
            "customer": "cus_Fg2S92JxFFvkvZ",
            "description": "TooU Purchase",
            "destination": null,
            "dispute": null,
            "failure_code": "card_declined",
            "failure_message": "Your card was declined.",
            "fraud_details": {
            },
            "invoice": null,
            "livemode": false,
            "metadata": {
              "order_id": "131",
              "customer_id": "28",
              "commitment_amount": "500"
            },
            "on_behalf_of": null,
            "order": null,
            "outcome": {
              "network_status": "not_sent_to_network",
              "reason": "highest_risk_level",
              "risk_level": "highest",
              "risk_score": 94,
              "rule": "block_if_high_risk",
              "seller_message": "Stripe blocked this payment as too risky.",
              "type": "blocked"
            },
            "paid": false,
            "payment_intent": "pi_1FDyGyF1DucEZKNDar4JWkTV",
            "payment_method": "pm_1FD1gEF1DucEZKNDHmzn0y9W",
            "payment_method_details": {
              "card": {
                "brand": "visa",
                "checks": {
                  "address_line1_check": null,
                  "address_postal_code_check": null,
                  "cvc_check": "pass"
                },
                "country": "US",
                "exp_month": 5,
                "exp_year": 2022,
                "fingerprint": "8ISVyNywUlB3Y3OR",
                "funding": "credit",
                "last4": "4954",
                "three_d_secure": {
                  "authenticated": false,
                  "succeeded": true,
                  "version": "1.0"
                },
                "wallet": null
              },
              "type": "card"
            },
            "receipt_email": null,
            "receipt_number": null,
            "receipt_url": "https://pay.stripe.com/receipts/acct_1DtKmzF1DucEZKND/ch_1FDyGyF1DucEZKNDWV67iZeh/rcpt_FjR92y2KsEfWHNsbDXtlUQDnae5Jod1",
            "refunded": false,
            "refunds": {
              "object": "list",
              "data": [
              ],
              "has_more": false,
              "total_count": 0,
              "url": "/v1/charges/ch_1FDyGyF1DucEZKNDWV67iZeh/refunds"
            },
            "review": null,
            "shipping": null,
            "source": null,
            "source_transfer": null,
            "statement_descriptor": null,
            "statement_descriptor_suffix": null,
            "status": "failed",
            "transfer_data": null,
            "transfer_group": "131"
          }
        ],
        "has_more": false,
        "total_count": 1,
        "url": "/v1/charges?payment_intent=pi_1FDyGyF1DucEZKNDar4JWkTV"
      },
      "client_secret": "pi_1FDyGyF1DucEZKNDar4JWkTV_secret_3vOFJa0C5ftTN0Q2xZWXQOUre",
      "confirmation_method": "manual",
      "created": 1567364376,
      "currency": "usd",
      "customer": "cus_Fg2S92JxFFvkvZ",
      "description": "TooU Purchase",
      "invoice": null,
      "last_payment_error": {
        "charge": "ch_1FDyGyF1DucEZKNDWV67iZeh",
        "code": "card_declined",
        "decline_code": "generic_decline",
        "doc_url": "https://stripe.com/docs/error-codes/card-declined",
        "message": "Your card was declined.",
        "payment_method": {
          "id": "pm_1FD1gEF1DucEZKNDHmzn0y9W",
          "object": "payment_method",
          "billing_details": {
            "address": {
              "city": null,
              "country": "US",
              "line1": null,
              "line2": null,
              "postal_code": null,
              "state": null
            },
            "email": null,
            "name": null,
            "phone": null
          },
          "card": {
            "brand": "visa",
            "checks": {
              "address_line1_check": null,
              "address_postal_code_check": null,
              "cvc_check": "pass"
            },
            "country": "US",
            "exp_month": 5,
            "exp_year": 2022,
            "fingerprint": "8ISVyNywUlB3Y3OR",
            "funding": "credit",
            "generated_from": null,
            "last4": "4954",
            "three_d_secure_usage": {
              "supported": true
            },
            "wallet": null
          },
          "created": 1567139146,
          "customer": "cus_Fg2S92JxFFvkvZ",
          "livemode": false,
          "metadata": {
          },
          "type": "card"
        },
        "type": "card_error"
      },
      "livemode": false,
      "metadata": {
        "order_id": "131",
        "customer_id": "28",
        "commitment_amount": "500"
      },
      "next_action": null,
      "on_behalf_of": null,
      "payment_method": null,
      "payment_method_options": {
        "card": {
          "request_three_d_secure": "automatic"
        }
      },
      "payment_method_types": [
        "card"
      ],
      "receipt_email": null,
      "review": null,
      "setup_future_usage": "on_session",
      "shipping": null,
      "source": null,
      "statement_descriptor": null,
      "statement_descriptor_suffix": null,
      "status": "requires_payment_method",
      "transfer_data": null,
      "transfer_group": "131"
    },
    "payment_method": {
      "id": "pm_1FD1gEF1DucEZKNDHmzn0y9W",
      "object": "payment_method",
      "billing_details": {
        "address": {
          "city": null,
          "country": "US",
          "line1": null,
          "line2": null,
          "postal_code": null,
          "state": null
        },
        "email": null,
        "name": null,
        "phone": null
      },
      "card": {
        "brand": "visa",
        "checks": {
          "address_line1_check": null,
          "address_postal_code_check": null,
          "cvc_check": "pass"
        },
        "country": "US",
        "exp_month": 5,
        "exp_year": 2022,
        "fingerprint": "8ISVyNywUlB3Y3OR",
        "funding": "credit",
        "generated_from": null,
        "last4": "4954",
        "three_d_secure_usage": {
          "supported": true
        },
        "wallet": null
      },
      "created": 1567139146,
      "customer": "cus_Fg2S92JxFFvkvZ",
      "livemode": false,
      "metadata": {
      },
      "type": "card"
    },
    "type": "card_error"
  }
}
EOS
    
end