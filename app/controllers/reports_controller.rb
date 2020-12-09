class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_server
  def handle
    report = params[:report].open

    csv_options = { col_sep: ',', headers: :first_row }

    CSV.parse(report, csv_options) do |timestamp, lock_id, kind, status|
      timestamp = timestamp[1]
      lock_id = Lock_id[1]
      kind = kind[1]
      status_change = status_change[1]
      lock = Lock.find(lock_id)

      if lock
        lock.status = status_change
        lock.save
      else
        lock = Lock.create(id: lock_id, kind: kind, status: status_change)
      end

      Entry.create(timestamp: timestamp, status_change: status_change, lock: lock)
    end
    render json: { message: "Processed" }
  end

  def authenticate_server
    code_name = request.headers["X-Server-Codename"]
    server = Server.find_by(code_name: code_name)
    access_token = request.headers["X-Server_Token"]
    unless server && server.access_token == access_token
      render json: { message: "wrong data" }
    end
  end
end
