
float pointInBounds(vector p, vector min, vector max)
{
	if(p_x < min_x)
		return FALSE;
	if(p_y < min_y)
		return FALSE;
	if(p_x > max_x)
		return FALSE;
	if(p_y > max_y)
		return FALSE;

	return TRUE;
}

float boundsInBounds(vector pmin, vector pmax, vector min, vector max)
{
	if(!(pointInBounds(pmin, min, max)))
		return FALSE;

	if(!(pointInBounds(pmax, min, max)))
		return FALSE;

	return TRUE;
}

vector centerPoint(vector bPos, vector bSize)
{
	return bPos + (bSize/2);
}

vector centerBounds(vector objSize, vector targPos, vector targSize)
{
//	return ((targPos + (targSize/2)) - objSize/2);
	return targPos - (objSize - targSize);
}


//should probably rewrite this to clamp to any arbitrary box
//with any arbitrary falloff
vector screenClamp(vector v)
{
	if(v_x > screen_size_x)
	{
		v_x = screen_size_x - (20 + 40);
	}

	if(v_x < 0)
	{
		v_x = (20 + 15);
	}

	if(v_y > screen_size_y)
	{
		v_y = screen_size_y - (20 + 15);
	}

	if(v_y < 0)
	{
		v_y = (20 + 15);
	}

	return v;
}