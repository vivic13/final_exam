class MessagesController < ApplicationController

  before_action :authenticate_user!, :except => [:index, :show]
  before_action :find_message, only:[:subscribe, :unsubscribe, :like, :unlike]
  def index
    # TODO: fix N+1 queries for user and comments
    @messages = Message.includes(:user,:comments).order("id DESC").page( params[:page] )

    if params[:status] == "pending"
      # TODO: @messages = @messages.pending
      @messages = @messages.pending
    elsif params[:status] == "completed"
      # TODO: @messages = @messages.completed
      @messages = @messages.completed
    end

    if params[:days]
      # TODO: @messages = @messages.within_days(params[:days].to_i)
      @messages = @messages.within_days(params[:days].to_i)
    end
  end

  def show
    @message = Message.find( params[:id] )
    @comment = Comment.new
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new( message_params )
    @message.user = current_user

    @message.save!

    redirect_to root_path
  end

  def edit
    @message = current_user.messages.find( params[:id] )

    render "new"
  end

  def update
    @message = current_user.messages.find( params[:id] )

    @message.update!( message_params )

    redirect_to message_path(@message)
  end

  def destroy
    @message = current_user.messages.find( params[:id] )
    @message.destroy

    redirect_to root_path
  end

  def subscribe
    @subscribe = Subscribe.create(:user => current_user, :message => @message)
    redirect_to root_path

  end

  def unsubscribe

    if @message.already_subscribed(current_user)
      @subscribe = @message.find_subscribe(current_user)
      @subscribe.destroy
      redirect_to root_path
    end

  end

  def like 
    
    @like = Like.create(:user => current_user, :message => @message)
    redirect_to root_path

  end

  def unlike
    if @message.already_liked(current_user)
      @like = @message.find_like(current_user)
      @like.destroy
      redirect_to root_path
    end

  end


  protected

  def message_params
    params.require(:message).permit(:title, :content, :category_name)
  end

  def find_message
    @message = Message.find(params[:id])
  end
end
