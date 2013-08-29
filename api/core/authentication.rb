require_relative 'orm'

class Authentication
  def authenticated?(session)
    session.has_key?(:user_id)
  end

  def get_user_from_session(session)
    user_id = session[:user_id]

    User.where(email: user_id).first
  end

  def has_plan?(session,plan)
    if authenticated?(session)
      user = get_user_from_session(session)
      if user.nil?
        user_plan = 'regular'
      else
        user_plan = user.plan
      end
    else
      user_plan = 'regular'
    end

    plan == user_plan
  end
end