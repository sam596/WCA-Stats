import db_init, connection

from import_new_db import cur
import os

ghpages_dir = "queries/gh-pages"

def parse_sql_metadata(file):
    title = description = summary = valrange = valfiles = ""
    for line in file:
            if line.startswith("##"):
                line = line.replace("##","")
                if line.startswith("title"):
                    title = line.replace("title","").strip()
                elif line.startswith("desc"):
                    description = line.replace("desc","").strip()
                elif line.startswith("summary"):
                    summary = line.replace("summary","").strip()
                elif line.startswith("valrange"):
                    valrange = line.replace("valrange","").strip()
                elif line.startswith("valfiles"):
                    valfiles = line.replace("valfiles","").strip()
    return title, description, summary, valrange, valfiles

def create_query_table(cur):
    rows = cur.fetchall()
    columns = [i[0] for i in cur.description]

    result = []
    
    for row in rows:
        row_dict = {}
        for i, column in enumerate(columns):
            row_dict[column] = row[i]
        result.append(row_dict)

    table = []
    last_rank = None

    for row in result:
        this_row = row.copy()
        for value in row:
            if value == "personId":
                this_row["URL"] = "https://www.worldcubeassociation.org/persons/" + row[value]
            elif value == "rank":
                if last_rank != None:
                    if row[value] == last_rank:
                        this_row["rank"] = "="
                last_rank = row[value]
        table.append(this_row)

    return table

def generate_html_table(table, headers):
    html_table = "<table>\n"
    html_table += "<tr>\n"

    for header in headers:
        html_table += "<th>{}</th>\n".format(header)
    html_table += "</tr>\n"

    for row in table:
        html_table += "<tr>\n"
        for header in headers:
            if header == "Person":
                html_table += "<td><a href='{}'>{}</a></td>\n".format(row["URL"], row["personName"])
            else:
                html_table += "<td>{}</td>\n".format(row.get(header, ""))
        html_table += "</tr>\n"

    html_table += "</table>"

    return html_table


for file in os.listdir(ghpages_dir):
    file_path = os.path.join(ghpages_dir, file)
    
    with open(file_path, "r") as f:
        title, description, summary, valrange, valfiles = parse_sql_metadata(f)

        if valrange == '':
            pass
        else:
            for x in eval(valrange):
                x_centi = x * 100
                f.seek(0)
                query = f.read().format(X=x, best=x_centi)
                cur.execute(query)

                headers = ["Rank", "Person", "Country", "Average", "Single"]
                table = create_query_table(cur)
                
                html_table = generate_html_table(table, headers)
                
                this_file = "docs/{}/{}.html".format(file.replace(".sql","",),valfiles.format(X=x))

                os.makedirs(os.path.dirname(this_file), exist_ok=True)

                with open("docs/template.html", "r") as f_template:
                    template = f_template.read()

                template = template.replace("<!-- title -->",title)
                template = template.replace("<!-- summary -->",summary)
                template = template.replace("<!-- description -->",description)
                template = template.replace("<!-- table -->",html_table)

                with open(this_file, "w+", encoding="utf-8") as f_out:
                    f_out.write(template)