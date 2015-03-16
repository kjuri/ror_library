json.array!(@reservations) do |reservation|
  json.extract! reservation, :reserved_on
  json.url reservation_url(reservation, format: :json)
end
