module ControllerMacros
  def let_valid_headers
    let(:headers) do
      {
          'X-User-Token' => user.authentication_token,
          'X-User-Email' => user.email,
          "HTTP_ACCEPT" => "application/json"
      }
    end
  end

  def let_wrong_email_headers
    let(:headers) do
      {
          'X-User-Token' => user.authentication_token,
          'X-User-Email' => 'fake@email.com',
          "HTTP_ACCEPT" => "application/json"
      }
    end
  end

  def let_wrong_token_headers
    let(:headers) do
      {
          'X-User-Token' => 'wrong-token',
          'X-User-Email' => user.email,
          "HTTP_ACCEPT" => "application/json"
      }
    end
  end

end