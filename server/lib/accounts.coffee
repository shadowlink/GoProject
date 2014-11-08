Meteor.startup ->
  #Conexión con el monitor Kadira
  Kadira.connect "9qQBC5gH8Bya2B8Be", "a863174e-f80b-4cdd-80b4-42a324f3abbe"
  
  # Eliminar la configuración de servicios si ya están configurados
  ServiceConfiguration.configurations.remove $or: [
    {
      service: "facebook"
    }
    {
      service: "google"
    }
  ]
  
  #Configuracion de cuentas de Google
  ServiceConfiguration.configurations.insert
    service: "google"
    clientId: "432101969834-j7dqmkkvrc143105q991eueojgngesj3.apps.googleusercontent.com"
    client_email: "432101969834-j7dqmkkvrc143105q991eueojgngesj3@developer.gserviceaccount.com"
    secret: "4PEFammbYmjG7CjJP7gO9M2d"
  
  
  #Configuracion de cuentas de Facebook
  ServiceConfiguration.configurations.insert
    service: "facebook"
    appId: "358857657622384"
    secret: "fe060d33b6b279570ae4c8d1f8083cfa"
  
  return