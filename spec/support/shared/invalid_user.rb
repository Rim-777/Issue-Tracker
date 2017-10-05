shared_examples_for 'InvalidUser' do
  it 'returns status 422' do
    request
    expect(response.status).to eq 422
  end

  it "doesn't change User count" do
    expect {request}.to_not change(User, :count)
  end

  it 'returns json according the schema' do
    request
    expect(response.body).to eq message
  end
end