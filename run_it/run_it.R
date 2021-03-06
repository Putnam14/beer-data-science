# run it

source("./get_beer.R")
source("./munge.R")
source("./collapse_styles.R")
source("./split_ingredients.R")


# --------------- get all raw beer and breweries --------------
# paginated_request() from get_beer.R
all_beer_raw <- paginated_request("beers", "&withIngredients=Y")

all_breweries <- paginated_request("breweries", "")  # if no addition desired, just add empty string

all_glassware <- paginated_request("glassware", "")


# --------------- get the columns we care about ---------------
# unnest_ingredients() from munge.R
all_beer <- unnest_ingredients(all_beer_raw) %>% as_tibble()

# keep only columns we care about
beer_necessities <- all_beer %>%
  rename(
    glass = glass.name,
    srm = srm.name,
    style = style.name
  ) %>% select(
    id, name, description, style,
    abv, ibu, srm, glass,
    hops_name, hops_id, malt_name, malt_id,
    glasswareId, styleId, style.categoryId
  )

# set types
beer_necessities$style <- factor(beer_necessities$style)
beer_necessities$styleId <- factor(beer_necessities$styleId)
beer_necessities$glass <- factor(beer_necessities$glass)

beer_necessities$ibu <- as.numeric(beer_necessities$ibu)
beer_necessities$srm <- as.numeric(beer_necessities$srm)
beer_necessities$abv <- as.numeric(beer_necessities$abv)


# ------------------- collapse styles ------------------- 
# collapse_styles() and collapse_further() from collapse_styles.R
beer_necessities$style_collapsed <- NA
beer_necessities <- collapse_styles(beer_necessities)

beer_necessities$style_collapsed <- factor(beer_necessities$style_collapsed)
beer_necessities <- collapse_further(beer_necessities)

# drop unused levels
droplevels(beer_necessities)$style_collapsed %>% as_tibble() 

# save this into beer_necessities_bundled as we'll use the name beer_necessities when we split out ingredients
beer_necessities_bundled <- beer_necessities


# ---------------- split out ingredients that were concatenated in `ingredient`_name
# split_ingredients() from split_ingredients.R

ingredients_2_split <- c("hops_name", "malt_name")
beer_necessities <- split_ingredients(beer_necessities_bundled, ingredients_2_split) 


# ------ simple beer necessities: random sample of 200
simple_beer_necessities <- sample_n(beer_necessities, 200)



# ------------------ pare to most popular styles ---------------
# ----- pare down by style or style_collapsed? -----
source("./most_popular_styles.R")

