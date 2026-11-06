class FinancesController < ApplicationController
  def show
    @active_tab = "finanzas"
    @settings = current_user
    @category_filter = params[:category].presence
    @transactions = current_user.financial_transactions.order(position: :asc, created_at: :desc).to_a
    @finance_summary = FinanceSummaryService.new(@transactions, budget_cents: current_user.monthly_budget_cents)
    @movements = if @category_filter.present?
      @transactions.select { |t| t.category == @category_filter }
    else
      @transactions
    end
  end

  def create_transaction
    euros = params[:amount].to_s.tr(",", ".").to_f
    cents = (euros * 100).round
    if cents > 0 && params[:concept].present?
      kind = params[:kind].presence || "expense"
      category = kind == "income" ? "Ingresos" : (params[:category].presence || "Comida")
      icon_name = case category
                  when "Transporte" then "train-front"
                  when "Otros" then "coffee-17"
                  else "shopping-basket"
                  end
      current_user.financial_transactions.update_all("position = position + 1")
      current_user.financial_transactions.create!(
        concept: params[:concept].strip,
        category: category,
        kind: kind,
        amount_cents: cents,
        date_label: params[:date_label].presence || "Hoy",
        icon_name: icon_name,
        visible_in_recent: true,
        position: 1
      )
      notice_msg = "#{kind == 'income' ? 'Ingreso' : 'Gasto'} «#{params[:concept].strip}» registrado."
    end
    redirect_to finances_path, notice: notice_msg
  end

  def update_budget
    euros = params[:monthly_budget].to_s.tr(".", "").tr(",", ".").to_f
    cents = (euros * 100).round
    if cents > 0
      current_user.update!(monthly_budget_cents: cents)
    end
    redirect_to finances_path, notice: "Presupuesto mensual actualizado."
  end

  def destroy_transaction
    tx = current_user.financial_transactions.find(params[:id])
    tx.destroy!
    redirect_to finances_path, notice: "Movimiento eliminado."
  end
end
