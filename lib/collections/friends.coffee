@Friends = new Meteor.Collection 'friends'

Meteor.methods
	inviteFriend: (sender, receiver) ->
		numInvites = Friends.find("sender._id":sender._id, "receiver._id": receiver._id).count()
		if numInvites is 0
			friend = 
				sender: sender
				receiver: receiver
				accepted:false
				submitted: new Date().getTime()
			Friends.insert friend

	acceptFriend: (friendId) ->
		f = Friends.find(_id:friendId).fetch()[0]
		friend = 
			sender: f.receiver
			receiver: f.sender
			accepted:true
			submitted: new Date().getTime()
		Friends.insert friend
		Friends.update
			_id: friendId,
			{
				$set:
				  accepted: true
			}

	cancelFriend: (friendId) ->
		Friends.remove _id:friendId

