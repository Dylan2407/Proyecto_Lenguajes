package ConexionSQLDB;

import Clasese.principales.Clientes;
import java.sql.Connection;
import java.sql.Date;
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
            ResultSet rs = st.executeQuery("SELECT ID_CLIENTE,CEDULA,NOMBRE,APELLIDO,TELEFONO,FECHAINGRESO,DIRECCION" + "    FROM TBL_CLIENTE ORDER BY 2");
            
            while (rs.next()){
                Clientes cl = new Clientes();
                cl.setId_cliente(rs.getInt("ID_CLIENTE"));
                cl.setNombre(rs.getString("NOMBRE"));
                cl.setApellido(rs.getString("APELLIDO"));
                cl.setCedula(rs.getInt("CEDULA"));
                cl.setTelefono(rs.getInt("TELEFONO"));
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
    
}
