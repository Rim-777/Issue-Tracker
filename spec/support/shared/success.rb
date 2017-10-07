shared_examples_for 'Success' do
  it 'returns status :ok' do
    request
    expect(response).to be_success
  end
end
