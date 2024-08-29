package ConexionSQLDB;

import Clasese.principales.Clientes;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;

public class ClienteDB {
    
    public ArrayList<Clientes> ListClientes(){
        ArrayList<Clientes> cliente = new ArrayList();
       
        
        try{
            
            Connection cnx = DataBaseConnect.getConnection();
            Statement st = cnx.createStatement();
            ResultSet rs = st.executeQuery("SELECT ID_CLIENTE,CEDULA,NOMBRE,APELLIDO,TELEFONO,FECHAINGRESO,DIRECCION" + " FROM TBL_CLIENTE");
            
            while (rs.next()){
                Clientes cl = new Clientes();
                cl.setId_cliente(rs.getInt("ID_CLIENTE"));
                cl.setNombre(rs.getString("NOMBRE"));
                cl.setApellido(rs.getString("APELLIDO"));
                cl.setCedula(rs.getLong("CEDULA"));
                cl.setTelefono(rs.getLong("TELEFONO"));
                cl.setDireccion(rs.getString("DIRECCION"));
                Date fechaIngresoSql = rs.getDate("FECHAINGRESO");
                LocalDate fechaIngreso = fechaIngresoSql.toLocalDate();
                cl.setFechaingreso(fechaIngreso);
                
                cliente.add(cl);
                
            }
            
        }catch(SQLException ex){
            System.out.println(ex.getMessage());
            System.out.println("Error en listado");
        }
        
        return cliente;
        
    }
    
    public boolean updateCliente(Clientes cliente) {
        Connection cnx = null;
        CallableStatement cstmt = null;
        boolean isUpdated = false;

        try {
            cnx = DataBaseConnect.getConnection();
            String sql = "{call sp_actualizar_cliente(?, ?, ?, ?, ?, ?, ?)}";
            cstmt = cnx.prepareCall(sql);

            // Set parameters for the stored procedure
            cstmt.setLong(1, cliente.getId_cliente());
            cstmt.setLong(2, cliente.getCedula()); // Adjust if using String
            cstmt.setString(3, cliente.getNombre());
            cstmt.setString(4, cliente.getApellido());
            cstmt.setLong(5, cliente.getTelefono()); // Adjust if using String
            cstmt.setDate(6, java.sql.Date.valueOf(cliente.getFechaingreso()));
            cstmt.setString(7, cliente.getDireccion());

            // Execute the stored procedure
            cstmt.execute();
            
            // Check if update was successful
            isUpdated = true;
            
        } catch (SQLException ex) {
            System.out.println("SQL State: " + ex.getSQLState());
            System.out.println("Error Code: " + ex.getErrorCode());
            System.out.println("Message: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            // Close resources
            try {
                if (cstmt != null) cstmt.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error closing resources: " + e.getMessage());
            }
        }
        
        return isUpdated;
    }
    
        public boolean deleteCliente(long idCliente) {
        Connection cnx = null;
        CallableStatement cstmt = null;
        boolean isDeleted = false;

        try {
            cnx = DataBaseConnect.getConnection();
            String sql = "{call sp_eliminar_cliente(?)}";
            cstmt = cnx.prepareCall(sql);

            // Set parameter for the stored procedure
            cstmt.setLong(1, idCliente);

            // Execute the stored procedure
            cstmt.execute();
            
            // If no exception occurred, we assume the procedure executed successfully
            isDeleted = true;
            
        } catch (SQLException ex) {
            System.out.println("SQL State: " + ex.getSQLState());
            System.out.println("Error Code: " + ex.getErrorCode());
            System.out.println("Message: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            // Close resources
            try {
                if (cstmt != null) cstmt.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error closing resources: " + e.getMessage());
            }
        }
        
        return isDeleted;
    }
    
}
