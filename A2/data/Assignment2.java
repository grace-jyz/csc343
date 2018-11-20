import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try { this.connection = DriverManager.getConnection(url + "?currentSchema=parlgov", username, password);
        } catch (SQLException se) { return false; }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        try { connection.close(); }
        catch (SQLException se) { return false; }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets = new ArrayList<>();

        try {
            PreparedStatement idStat = connection.prepareStatement("SELECT id FROM country WHERE name=?");
            idStat.setString(1, countryName);
            ResultSet idSet = idStat.executeQuery();

            int countryID;
            if (idSet.next()) countryID = idSet.getInt("id");
            else return null;  // countryName not found

            PreparedStatement electionStat = connection.prepareStatement(
                "SELECT id FROM election WHERE country_id=? ORDER BY e_date DESC");
            electionStat.setInt(1, countryID);
            ResultSet electionSet = electionStat.executeQuery();

            while (electionSet.next()) {
                int electionID = electionSet.getInt("id");
                elections.add(electionID);

                // get type of election
                PreparedStatement typeStat = connection.prepareStatement(
                    "SELECT e_type, previous_parliament_election_id, previous_ep_election_id FROM election WHERE id=?")
                typeStat.setInt(1, electionID);
                ResultSet typeSet = typeSet.executeQuery();

                typeSet.next();
                String electionType = typeSet.getString("e_type");
                // get next election of same type
                String nextElectionID;
                if (electionType.equals("European Parliament"))
                    nextElectionID = typeSet.getString("previous_ep_election_id")
                else
                    nextElectionID = typeSet.getString("previous_parliament_election_id");
                
                // get date of previous election
                if (nextElectionID is null) {

                } else {
                    
                }
                // find cabinets between that date and the current electionid date
                // add cabinets to cabinets list
            }
        } catch (SQLException se) { return null; }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        return null;
    }

    public static void main(String[] args) {
        try {
            Assignment2 test = new Assignment2();

            test.connectDB("jdbc:postgresql://localhost:5432/csc343h-choihy38", "choihy38", "");
            // System.out.println(test.electionSequence("Japan").toString());
            test.disconnectDB();
        } catch (ClassNotFoundException e) { return; }
    }

}

